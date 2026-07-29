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

class ExerciseNotifier extends Notifier<AsyncValue<ExerciseData>> with WidgetsBindingObserver {
  late GetSessionItemsUseCase _getItems;
  late SubmitResponsesUseCase _submitResponses;
  late DiagnoseUseCase _diagnose;

  int Function() _ttsPlaybackMs = () => TtsService.instance.playbackMs;
  void Function() _resetTtsPlayback = () => TtsService.instance.resetPlaybackTimer();

  @visibleForTesting
  void debugSetTtsHooks({required int Function() playbackMs, required void Function() resetPlayback}) {
    _ttsPlaybackMs = playbackMs;
    _resetTtsPlayback = resetPlayback;
  }

  String? _sessionId;
  final List<ItemResponseSubmission> _collected = [];

  final Stopwatch _itemTimer = Stopwatch();

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

  void _startItemTimer() {
    _resetTtsPlayback();
    _backgroundTimer
      ..stop()
      ..reset();
    _itemTimer
      ..reset()
      ..start();
  }

  void answer(String rawResponse, {String captureModality = 'tactil', double? sttConfidence}) {
    final data = state.valueOrNull;
    final current = data?.current;
    if (current == null) return;
    final totalMs = _itemTimer.elapsedMilliseconds;
    final ttsMs = _ttsPlaybackMs();
    final netMs = (totalMs - ttsMs).clamp(0, totalMs);
    final estimulo = current.stimulusText.trim();
    _collected.add(ItemResponseSubmission(
      itemId: current.itemId,
      rawResponse: rawResponse,
      responseTimeMs: netMs,
      captureModality: captureModality,
      sttConfidence: sttConfidence,
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
