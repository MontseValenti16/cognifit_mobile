import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/tracking_entity.dart';
import '../../domain/usecases/get_learning_curve_usecase.dart';
import '../../domain/usecases/get_student_metrics_usecase.dart';

enum LearningCurveStatus { idle, loading, loaded, error }

class LearningCurveViewModel extends ChangeNotifier {
  final GetLearningCurveUseCase _getLearningCurve;
  final GetStudentMetricsUseCase _getStudentMetrics;

  LearningCurveViewModel({
    required GetLearningCurveUseCase getLearningCurve,
    required GetStudentMetricsUseCase getStudentMetrics,
  })  : _getLearningCurve = getLearningCurve, _getStudentMetrics = getStudentMetrics;

  LearningCurveStatus _status = LearningCurveStatus.idle;
  LearningCurveEntity? _curve;
  StudentMetricsEntity? _metrics;
  String? _error;

  LearningCurveStatus get status => _status;
  LearningCurveEntity? get curve => _curve;
  StudentMetricsEntity? get metrics => _metrics;
  String? get error => _error;
  bool get isLoading => _status == LearningCurveStatus.loading;

  Future<void> load(String studentId) async {
    _status = LearningCurveStatus.loading; notifyListeners();
    try {
      _curve = await _getLearningCurve(studentId);
      _metrics = await _getStudentMetrics(studentId);
      _status = LearningCurveStatus.loaded;
    } on ApiException catch (e) {
      _error = e.userMessage; _status = LearningCurveStatus.error;
    } catch (_) {
      _error = 'No se pudo cargar el progreso.'; _status = LearningCurveStatus.error;
    }
    notifyListeners();
  }
}
