import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/domain/usecases/get_student_by_id_usecase.dart';
import '../../../tests/domain/entities/screening_entity.dart';
import '../../../tests/domain/usecases/get_latest_risk_usecase.dart';
import '../../../tests/domain/usecases/get_student_assignments_usecase.dart';
import '../../../tests/domain/usecases/open_session_usecase.dart';
import '../../../tracking/domain/entities/tracking_entity.dart';
import '../../../tracking/domain/usecases/get_student_metrics_usecase.dart';

enum StudentProfileStatus { idle, loading, loaded, error }

/// Composes backend resources into one screen:
/// GET /students/{id} + GET /screening/students/{id}/latest-risk
/// + GET /tracking/students/{id}/metrics
/// + GET /screening/students/{id}/assignments
class StudentProfileViewModel extends ChangeNotifier {
  final GetStudentByIdUseCase _getStudent;
  final GetLatestRiskUseCase _getLatestRisk;
  final GetStudentMetricsUseCase _getMetrics;
  final GetStudentAssignmentsUseCase _getAssignments;
  final OpenSessionUseCase _openSession;

  StudentProfileViewModel({
    required GetStudentByIdUseCase getStudent,
    required GetLatestRiskUseCase getLatestRisk,
    required GetStudentMetricsUseCase getMetrics,
    required GetStudentAssignmentsUseCase getAssignments,
    required OpenSessionUseCase openSession,
  })  : _getStudent = getStudent,
        _getLatestRisk = getLatestRisk,
        _getMetrics = getMetrics,
        _getAssignments = getAssignments,
        _openSession = openSession;

  StudentProfileStatus _status = StudentProfileStatus.idle;
  StudentEntity? student;
  DiagnosisEntity? latestRisk;
  StudentMetricsEntity? metrics;
  List<PendingModuleEntity> pendingModules = [];
  String? error;
  String? openingAssignmentId;

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
      try { metrics = await _getMetrics(studentId); } catch (_) { metrics = null; }
      try { pendingModules = await _getAssignments(studentId); } catch (_) { pendingModules = []; }
      _status = StudentProfileStatus.loaded;
    } on ApiException catch (e) {
      error = e.userMessage; _status = StudentProfileStatus.error;
    } catch (_) {
      error = 'No se pudo cargar el perfil del alumno.'; _status = StudentProfileStatus.error;
    }
    notifyListeners();
  }

  /// Opens (or resumes) a session for the given assignment and returns
  /// the session id + module name so the caller can navigate to ExerciseScreen.
  Future<({String sessionId, String moduleTitle})?> openModule(PendingModuleEntity module) async {
    openingAssignmentId = module.assignmentId;
    notifyListeners();
    try {
      final session = await _openSession(
        assignmentId: module.assignmentId,
        moduleCode: module.moduleCode,
        deviceId: 'flutter-app',
        appVersion: '1.0.0',
      );
      return (sessionId: session.id, moduleTitle: module.moduleName);
    } catch (e) {
      if (kDebugMode) debugPrint('openModule error: $e');
      return null;
    } finally {
      openingAssignmentId = null;
      notifyListeners();
    }
  }
}
