import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../di/intervention_providers.dart';
import '../../domain/entities/intervention_entity.dart';
import '../../domain/usecases/get_active_path_usecase.dart';
import '../../domain/usecases/next_exercise_usecase.dart';

enum InterventionPhase { active, complete, noPath }

class InterventionData {
  final InterventionPhase phase;
  final ActivePathEntity? path;
  final NextExerciseEntity? current;
  const InterventionData({required this.phase, this.path, this.current});
}

class InterventionNotifier extends AutoDisposeNotifier<AsyncValue<InterventionData>> {
  late GetActivePathUseCase _getActivePath;
  late NextExerciseUseCase _nextExercise;
  ActivePathEntity? _path;
  final List<Map<String, dynamic>> _sessionHistory = [];

  @override
  AsyncValue<InterventionData> build() {
    final repo = ref.watch(interventionRepositoryProvider);
    _getActivePath = GetActivePathUseCase(repo);
    _nextExercise = NextExerciseUseCase(repo);
    return const AsyncValue.loading();
  }

  Future<void> load(String studentId) async {
    _sessionHistory.clear();
    _path = null;
    state = const AsyncValue.loading();
    try {
      _path = await _getActivePath(studentId);
      state = await _fetchNext(studentId);
    } on ApiException catch (e, st) {
      state = e.statusCode == 404
          ? const AsyncValue.data(InterventionData(phase: InterventionPhase.noPath))
          : AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> recordAndAdvance(String studentId, double accuracy) async {
    final current = state.valueOrNull?.current;
    if (current == null || current.exerciseId == null) return;
    _sessionHistory.add({'exercise_id': current.exerciseId!, 'accuracy': accuracy});
    state = const AsyncValue.loading();
    try {
      state = await _fetchNext(studentId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AsyncValue<InterventionData>> _fetchNext(String studentId) async {
    if (_path == null) return state;
    final next = await _nextExercise(
      studentId: studentId,
      currentRoute: _path!.exerciseRoute,
      sessionHistory: _sessionHistory,
    );
    return AsyncValue.data(InterventionData(
      phase: next.isComplete ? InterventionPhase.complete : InterventionPhase.active,
      path: _path,
      current: next,
    ));
  }

  void reset() {
    _path = null;
    _sessionHistory.clear();
    state = const AsyncValue.loading();
  }
}

final interventionViewModelProvider =
    NotifierProvider.autoDispose<InterventionNotifier, AsyncValue<InterventionData>>(InterventionNotifier.new);

String interventionErrorMessage(Object error) => error is ApiException ? error.userMessage : 'No se pudo cargar la ruta de intervención.';
