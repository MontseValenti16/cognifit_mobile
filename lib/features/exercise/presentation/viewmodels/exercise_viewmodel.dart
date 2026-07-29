import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/services/tts_service.dart';
import '../../../tests/di/tests_providers.dart';
import '../../../tests/domain/entities/screening_entity.dart';
import '../../../tests/domain/usecases/get_session_items_usecase.dart';
import '../../../tests/domain/usecases/submit_responses_usecase.dart';
import '../../../tests/domain/usecases/diagnose_usecase.dart';

enum ExercisePhase { active, submitting, completed }

/// `submitting`/`completed` viven como fase dentro de `data`, no como un
/// AsyncValue.loading()/data() distinto: la pantalla necesita seguir
/// mostrando el spinner CON el texto "Generando diagnóstico..." (una UI
/// propia), y AsyncValue.loading() por sí solo no distingue eso de la carga
/// inicial de la sesión. AsyncValue.loading() queda reservado para esa carga
/// inicial; AsyncError cubre tanto el fallo de carga como el de envío —igual
/// que antes, ambos caían en la misma pantalla de error genérica.
class ExerciseData {
  final List<SessionItemEntity> items;
  final int currentIndex;
  final String? selectedAnswer;
  final bool? lastAnswerCorrect;
  final DiagnosisEntity? diagnosis;
  final ExercisePhase phase;

  const ExerciseData({
    this.items = const [],
    this.currentIndex = 0,
    this.selectedAnswer,
    this.lastAnswerCorrect,
    this.diagnosis,
    this.phase = ExercisePhase.active,
  });

  SessionItemEntity? get current => items.isEmpty || currentIndex >= items.length ? null : items[currentIndex];
  int get totalItems => items.length;
  double get progress => items.isEmpty ? 0 : currentIndex / items.length;

  ExerciseData copyWith({
    List<SessionItemEntity>? items,
    int? currentIndex,
    Object? selectedAnswer = _unset,
    Object? lastAnswerCorrect = _unset,
    DiagnosisEntity? diagnosis,
    ExercisePhase? phase,
  }) {
    return ExerciseData(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: identical(selectedAnswer, _unset) ? this.selectedAnswer : selectedAnswer as String?,
      lastAnswerCorrect: identical(lastAnswerCorrect, _unset) ? this.lastAnswerCorrect : lastAnswerCorrect as bool?,
      diagnosis: diagnosis ?? this.diagnosis,
      phase: phase ?? this.phase,
    );
  }
}

const _unset = Object();

String exerciseErrorMessage(Object error, {required bool duringSubmit}) {
  if (error is ApiException) return error.userMessage;
  return duringSubmit ? 'No se pudo generar el diagnóstico.' : 'No se pudieron cargar los ítems de la sesión.';
}

/// Drives a single screening session: GET items -> collect answers ->
/// POST responses -> POST diagnose. Maps to API_UI_GUIA section 4 steps 3-5.
class ExerciseNotifier extends Notifier<AsyncValue<ExerciseData>> with WidgetsBindingObserver {
  late GetSessionItemsUseCase _getItems;
  late SubmitResponsesUseCase _submitResponses;
  late DiagnoseUseCase _diagnose;

  /// Cuánto sonó el TTS en el ítem actual y cómo reiniciarlo. Reemplazables
  /// en pruebas para no depender de los canales de plataforma de flutter_tts.
  int Function() _ttsPlaybackMs = () => TtsService.instance.playbackMs;
  void Function() _resetTtsPlayback = () => TtsService.instance.resetPlaybackTimer();

  @visibleForTesting
  void debugSetTtsHooks({required int Function() playbackMs, required void Function() resetPlayback}) {
    _ttsPlaybackMs = playbackMs;
    _resetTtsPlayback = resetPlayback;
  }

  String? _sessionId;
  final List<ItemResponseSubmission> _collected = [];

  /// Stopwatch en vez de DateTime.now(): es monotónico, así que no lo afecta
  /// un ajuste de hora del sistema, y se puede pausar cuando la app pasa a
  /// segundo plano.
  final Stopwatch _itemTimer = Stopwatch();

  /// Acumulado del tiempo que el ítem actual pasó con la app en segundo plano.
  /// Se registra para poder auditarlo, aunque ya está excluido de _itemTimer.
  final Stopwatch _backgroundTimer = Stopwatch();

  @override
  AsyncValue<ExerciseData> build() {
    final repo = ref.watch(screeningRepositoryProvider);
    _getItems = GetSessionItemsUseCase(repo);
    _submitResponses = SubmitResponsesUseCase(repo);
    _diagnose = DiagnoseUseCase(repo);
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    return const AsyncValue.data(ExerciseData());
  }

  /// El tiempo de respuesta alimenta la feature con más peso del diagnóstico,
  /// así que no debe correr mientras la app está en segundo plano: antes, un
  /// niño que salía de la app volvía con un tiempo enorme que además disparaba
  /// el timeout de 15s y se registraba como omisión.
  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    final data = state.valueOrNull;
    if (appState == AppLifecycleState.resumed) {
      if (_backgroundTimer.isRunning) _backgroundTimer.stop();
      if (data != null && data.items.isNotEmpty && data.phase == ExercisePhase.active) _itemTimer.start();
    } else {
      if (_itemTimer.isRunning) {
        _itemTimer.stop();
        _backgroundTimer.start();
      }
    }
  }

  /// Respuestas acumuladas todavía sin enviar. Expuesto solo para pruebas del
  /// cálculo de tiempos (ver test/exercise_timing_test.dart).
  @visibleForTesting
  List<ItemResponseSubmission> get debugCollected => List.unmodifiable(_collected);

  Future<void> loadSession(String sessionId) async {
    _sessionId = sessionId;
    state = const AsyncValue.loading();
    try {
      final result = await _getItems(sessionId);
      _collected.clear();
      _startItemTimer();
      state = AsyncValue.data(ExerciseData(items: result.items));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Arranca el cronómetro del ítem desde cero y reinicia el contador de
  /// reproducción del TTS, para que cada ítem mida solo su propio audio.
  void _startItemTimer() {
    _resetTtsPlayback();
    _backgroundTimer
      ..stop()
      ..reset();
    _itemTimer
      ..reset()
      ..start();
  }

  /// Records the answer locally; advances automatically.
  /// [captureModality] e.g. "tactil", "stt", "teclado" — per item.input_modes
  void answer(String rawResponse, {String captureModality = 'tactil', double? sttConfidence}) {
    final data = state.valueOrNull;
    final current = data?.current;
    if (current == null) return;
    final totalMs = _itemTimer.elapsedMilliseconds;
    // Descontar lo que estuvo sonando la bocina: el apoyo auditivo está para
    // usarse, y antes su duración se sumaba al tiempo de respuesta, que es la
    // señal de mayor peso del diagnóstico. Un niño fluido que escuchaba el
    // audio dos veces terminaba pareciendo lento (subtipo "fluidez").
    final ttsMs = _ttsPlaybackMs();
    final netMs = (totalMs - ttsMs).clamp(0, totalMs);
    final estimulo = current.stimulusText.trim();
    _collected.add(ItemResponseSubmission(
      itemId: current.itemId,
      rawResponse: rawResponse,
      responseTimeMs: netMs,
      captureModality: captureModality,
      sttConfidence: sttConfidence,
      // Se guarda el desglose para poder auditar de donde salio el tiempo y
      // para alimentar mejores metricas en un reentrenamiento futuro. La
      // longitud del estimulo importa: hoy leer "b" y responder "¿Cuantas
      // silabas tiene mariposa?" se promedian en el mismo numero.
      timingDetail: ResponseTimingDetail(
        totalMs: totalMs + _backgroundTimer.elapsedMilliseconds,
        ttsMs: ttsMs,
        backgroundMs: _backgroundTimer.elapsedMilliseconds,
        netMs: netMs,
        stimulusChars: estimulo.length,
        stimulusWords: estimulo.isEmpty ? 0 : estimulo.split(RegExp(r'\s+')).length,
        difficulty: current.difficulty,
      ),
    ));
    final expected = current.expectedResponse?.trim();
    final correct = (expected == null || expected.isEmpty)
        ? null
        : rawResponse.trim().toLowerCase() == expected.toLowerCase();
    state = AsyncValue.data(data!.copyWith(selectedAnswer: rawResponse, lastAnswerCorrect: correct));
  }

  void nextItem() {
    final data = state.valueOrNull;
    if (data == null) return;
    if (data.currentIndex < data.items.length - 1) {
      _startItemTimer();
      state = AsyncValue.data(data.copyWith(
        currentIndex: data.currentIndex + 1,
        selectedAnswer: null,
        lastAnswerCorrect: null,
      ));
    } else {
      state = AsyncValue.data(data.copyWith(selectedAnswer: null, lastAnswerCorrect: null));
      _finishSession();
    }
  }

  Future<void> _finishSession() async {
    final data = state.valueOrNull;
    if (_sessionId == null || data == null) return;
    state = AsyncValue.data(data.copyWith(phase: ExercisePhase.submitting));
    try {
      await _submitResponses(_sessionId!, _collected);
      final diagnosis = await _diagnose(_sessionId!);
      state = AsyncValue.data(data.copyWith(phase: ExercisePhase.completed, diagnosis: diagnosis));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    _sessionId = null;
    _collected.clear();
    state = const AsyncValue.data(ExerciseData());
  }
}

final exerciseViewModelProvider = NotifierProvider<ExerciseNotifier, AsyncValue<ExerciseData>>(ExerciseNotifier.new);
