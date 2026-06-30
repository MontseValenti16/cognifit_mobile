import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/domain/usecases/get_student_by_id_usecase.dart';
import '../../../tests/domain/entities/screening_entity.dart';
import '../../../tests/domain/usecases/get_latest_risk_usecase.dart';
import '../../../tracking/domain/entities/tracking_entity.dart';
import '../../../tracking/domain/usecases/get_student_metrics_usecase.dart';

enum StudentProfileStatus { idle, loading, loaded, error }

/// Composes three backend resources into one screen:
/// GET /students/{id} + GET /screening/students/{id}/latest-risk + GET /tracking/students/{id}/metrics
class StudentProfileViewModel extends ChangeNotifier {
  final GetStudentByIdUseCase _getStudent;
  final GetLatestRiskUseCase _getLatestRisk;
  final GetStudentMetricsUseCase _getMetrics;

  StudentProfileViewModel({
    required GetStudentByIdUseCase getStudent,
    required GetLatestRiskUseCase getLatestRisk,
    required GetStudentMetricsUseCase getMetrics,
  })  : _getStudent = getStudent, _getLatestRisk = getLatestRisk, _getMetrics = getMetrics;

  StudentProfileStatus _status = StudentProfileStatus.idle;
  StudentEntity? student;
  DiagnosisEntity? latestRisk;
  StudentMetricsEntity? metrics;
  String? error;

  StudentProfileStatus get status => _status;
  bool get isLoading => _status == StudentProfileStatus.loading;
  bool get hasDiagnosis => latestRisk != null;

  Future<void> load(String studentId) async {
    _status = StudentProfileStatus.loading;
    error = null;
    notifyListeners();
    try {
      student = await _getStudent(studentId);
      latestRisk = await _getLatestRisk(studentId);
      try {
        metrics = await _getMetrics(studentId);
      } catch (_) {
        metrics = null;
      }
      _status = StudentProfileStatus.loaded;
    } on ApiException catch (e) {
      error = e.userMessage; _status = StudentProfileStatus.error;
    } catch (_) {
      error = 'No se pudo cargar el perfil del alumno.'; _status = StudentProfileStatus.error;
    }
    notifyListeners();
  }
}
