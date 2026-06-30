import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/intervention_entity.dart';
import '../../domain/usecases/get_active_path_usecase.dart';
import '../../domain/usecases/next_exercise_usecase.dart';

enum InterventionStatus { idle, loading, active, loadingNext, complete, noPath, error }

class InterventionViewModel extends ChangeNotifier {
  final GetActivePathUseCase _getActivePath;
  final NextExerciseUseCase _nextExercise;

  InterventionViewModel({
    required GetActivePathUseCase getActivePath,
    required NextExerciseUseCase nextExercise,
  })  : _getActivePath = getActivePath,
        _nextExercise = nextExercise;

  InterventionStatus _status = InterventionStatus.idle;
  String? _error;
  ActivePathEntity? _path;
  NextExerciseEntity? _current;
  final List<Map<String, dynamic>> _sessionHistory = [];

  InterventionStatus get status => _status;
  String? get error => _error;
  NextExerciseEntity? get current => _current;
  ActivePathEntity? get path => _path;
  bool get isLoading => _status == InterventionStatus.loading || _status == InterventionStatus.loadingNext;

  Future<void> load(String studentId) async {
    _status = InterventionStatus.loading;
    _sessionHistory.clear();
    _current = null;
    _error = null;
    notifyListeners();
    try {
      _path = await _getActivePath(studentId);
      await _fetchNext(studentId);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        _status = InterventionStatus.noPath;
      } else {
        _error = e.userMessage;
        _status = InterventionStatus.error;
      }
    } catch (_) {
      _error = 'No se pudo cargar la ruta de intervención.';
      _status = InterventionStatus.error;
    }
    notifyListeners();
  }

  Future<void> recordAndAdvance(String studentId, double accuracy) async {
    final ex = _current;
    if (ex == null || ex.exerciseId == null) return;
    _sessionHistory.add({'exercise_id': ex.exerciseId!, 'accuracy': accuracy});
    _status = InterventionStatus.loadingNext;
    notifyListeners();
    try {
      await _fetchNext(studentId);
    } catch (_) {
      _error = 'Error al obtener el siguiente ejercicio.';
      _status = InterventionStatus.error;
    }
    notifyListeners();
  }

  Future<void> _fetchNext(String studentId) async {
    if (_path == null) return;
    final next = await _nextExercise(
      studentId: studentId,
      currentRoute: _path!.exerciseRoute,
      sessionHistory: _sessionHistory,
    );
    _current = next;
    _status = next.isComplete ? InterventionStatus.complete : InterventionStatus.active;
  }

  void reset() {
    _status = InterventionStatus.idle;
    _error = null;
    _path = null;
    _current = null;
    _sessionHistory.clear();
    notifyListeners();
  }
}
