import 'package:flutter/widgets.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/services/tts_service.dart';
import '../../../tests/domain/entities/screening_entity.dart';
import '../../../tests/domain/usecases/get_session_items_usecase.dart';
import '../../../tests/domain/usecases/submit_responses_usecase.dart';
import '../../../tests/domain/usecases/diagnose_usecase.dart';

enum ExerciseStatus { idle, loading, active, submitting, completed, error }

/// Drives a single screening session: GET items -> collect answers ->
/// POST responses -> POST diagnose. Maps to API_UI_GUIA section 4 steps 3-5.
class ExerciseViewModel extends ChangeNotifier with WidgetsBindingObserver {
  final GetSessionItemsUseCase _getItems;
  final SubmitResponsesUseCase _submitResponses;
  final DiagnoseUseCase _diagnose;

  /// Cuánto sonó el TTS en el ítem actual y cómo reiniciarlo. Se inyectan para
  /// poder testear el descuento de audio sin depender de los canales de
  /// plataforma de flutter_tts; por defecto usan el servicio real.
  final int Function() _ttsPlaybackMs;
  final void Function() _resetTtsPlayback;

  ExerciseViewModel({
    required GetSessionItemsUseCase getItems,
    required SubmitResponsesUseCase submitResponses,
    required DiagnoseUseCase diagnose,
    int Function()? ttsPlaybackMs,
    void Function()? resetTtsPlayback,
  })  : _getItems = getItems,
        _submitResponses = submitResponses,
        _diagnose = diagnose,
        _ttsPlaybackMs = ttsPlaybackMs ?? (() => TtsService.instance.playbackMs),
        _resetTtsPlayback = resetTtsPlayback ?? (() => TtsService.instance.resetPlaybackTimer()) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// El tiempo de respuesta alimenta la feature con más peso del diagnóstico,
  /// así que no debe correr mientras la app está en segundo plano: antes, un
  /// niño que salía de la app volvía con un tiempo enorme que además disparaba
  /// el timeout de 15s y se registraba como omisión.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_items.isNotEmpty && _status == ExerciseStatus.active) _itemTimer.start();
    } else {
      if (_itemTimer.isRunning) _itemTimer.stop();
    }
  }

  ExerciseStatus _status = ExerciseStatus.idle;
  String? _error;
  String? _sessionId;
  List<SessionItemEntity> _items = [];
  int _currentIndex = 0;
  final List<ItemResponseSubmission> _collected = [];

  /// Stopwatch en vez de DateTime.now(): es monotónico, así que no lo afecta
  /// un ajuste de hora del sistema, y se puede pausar cuando la app pasa a
  /// segundo plano.
  final Stopwatch _itemTimer = Stopwatch();
  String? _selectedAnswer;
  DiagnosisEntity? _diagnosis;
  bool? _lastAnswerCorrect;

  ExerciseStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == ExerciseStatus.loading;
  bool get isSubmitting => _status == ExerciseStatus.submitting;
  bool get isCompleted => _status == ExerciseStatus.completed;
  SessionItemEntity? get current => _items.isEmpty || _currentIndex >= _items.length ? null : _items[_currentIndex];
  int get currentIndex => _currentIndex;
  int get totalItems => _items.length;
  double get progress => _items.isEmpty ? 0 : _currentIndex / _items.length;
  String? get selectedAnswer => _selectedAnswer;
  DiagnosisEntity? get diagnosis => _diagnosis;
  /// Null si el ítem no tiene respuesta esperada conocida (sin feedback inmediato).
  bool? get lastAnswerCorrect => _lastAnswerCorrect;

  /// Respuestas acumuladas todavía sin enviar. Expuesto solo para pruebas del
  /// cálculo de tiempos (ver test/exercise_timing_test.dart).
  @visibleForTesting
  List<ItemResponseSubmission> get debugCollected => List.unmodifiable(_collected);

  Future<void> loadSession(String sessionId) async {
    _sessionId = sessionId;
    _status = ExerciseStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final result = await _getItems(sessionId);
      _items = result.items;
      _currentIndex = 0;
      _collected.clear();
      _startItemTimer();
      _status = ExerciseStatus.active;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = ExerciseStatus.error;
    } catch (_) {
      _error = 'No se pudieron cargar los ítems de la sesión.'; _status = ExerciseStatus.error;
    }
    notifyListeners();
  }

  /// Arranca el cronómetro del ítem desde cero y reinicia el contador de
  /// reproducción del TTS, para que cada ítem mida solo su propio audio.
  void _startItemTimer() {
    _resetTtsPlayback();
    _itemTimer
      ..reset()
      ..start();
  }

  /// Records the answer locally; advances automatically.
  /// [captureModality] e.g. "tactil", "stt", "teclado" — per item.input_modes
  void answer(String rawResponse, {String captureModality = 'tactil', double? sttConfidence}) {
    if (current == null) return;
    final totalMs = _itemTimer.elapsedMilliseconds;
    // Descontar lo que estuvo sonando la bocina: el apoyo auditivo está para
    // usarse, y antes su duración se sumaba al tiempo de respuesta, que es la
    // señal de mayor peso del diagnóstico. Un niño fluido que escuchaba el
    // audio dos veces terminaba pareciendo lento (subtipo "fluidez").
    final ttsMs = _ttsPlaybackMs();
    final netMs = (totalMs - ttsMs).clamp(0, totalMs);
    _collected.add(ItemResponseSubmission(
      itemId: current!.itemId,
      rawResponse: rawResponse,
      responseTimeMs: netMs,
      captureModality: captureModality,
      sttConfidence: sttConfidence,
    ));
    _selectedAnswer = rawResponse;
    final expected = current!.expectedResponse?.trim();
    _lastAnswerCorrect = (expected == null || expected.isEmpty)
        ? null
        : rawResponse.trim().toLowerCase() == expected.toLowerCase();
    notifyListeners();
  }

  void nextItem() {
    _selectedAnswer = null;
    _lastAnswerCorrect = null;
    if (_currentIndex < _items.length - 1) {
      _currentIndex++;
      _startItemTimer();
      notifyListeners();
    } else {
      _finishSession();
    }
  }

  Future<void> _finishSession() async {
    if (_sessionId == null) return;
    _status = ExerciseStatus.submitting;
    notifyListeners();
    try {
      await _submitResponses(_sessionId!, _collected);
      _diagnosis = await _diagnose(_sessionId!);
      _status = ExerciseStatus.completed;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = ExerciseStatus.error;
    } catch (_) {
      _error = 'No se pudo generar el diagnóstico.'; _status = ExerciseStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _sessionId = null; _items = []; _currentIndex = 0; _collected.clear();
    _selectedAnswer = null; _diagnosis = null; _lastAnswerCorrect = null; _status = ExerciseStatus.idle;
    notifyListeners();
  }
}
