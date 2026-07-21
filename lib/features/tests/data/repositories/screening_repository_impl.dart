import '../../../../core/offline/local_response_queue.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/entities/screening_entity.dart';
import '../../domain/repositories/screening_repository.dart';
import '../datasources/screening_remote_datasource.dart';

class ScreeningRepositoryImpl implements ScreeningRepository {
  final ScreeningRemoteDataSource remote;
  const ScreeningRepositoryImpl(this.remote);

  @override
  Future<List<TeacherItemEntity>> getTeacherItems({int? grade}) =>
      remote.getTeacherItems(grade: grade);

  @override
  Future<TeacherResultEntity> submitTeacherResults(String studentId, List<TeacherAnswer> answers) =>
      remote.submitTeacherResults(studentId, answers);

  @override
  Future<List<ScreeningModuleEntity>> getCatalog() => remote.getCatalog();

  @override
  Future<AssignmentResultEntity> assignBattery(String studentId, double teacherScore, List<RiskFlag> riskFlags) =>
      remote.assignBattery(studentId, teacherScore, riskFlags);

  @override
  Future<ScreeningSessionEntity> openSession({required String assignmentId, required String moduleCode, String? deviceId, String? appVersion}) =>
      remote.openSession(assignmentId: assignmentId, moduleCode: moduleCode, deviceId: deviceId, appVersion: appVersion);

  @override
  Future<SessionItemsResultEntity> getSessionItems(String sessionId) => remote.getSessionItems(sessionId);

  @override
  Future<List<ResponseResultEntity>> submitResponses(String sessionId, List<ItemResponseSubmission> responses) async {
    if (!ConnectivityService.instance.isOnline) {
      await LocalResponseQueue.instance.enqueue(sessionId, responses);
      return [];
    }
    return remote.submitResponses(sessionId, responses);
  }

  @override
  Future<DiagnosisEntity> diagnose(String sessionId) => remote.diagnose(sessionId);

  @override
  Future<DiagnosisEntity?> getLatestRisk(String studentId) => remote.getLatestRisk(studentId);

  @override
  Future<List<PendingModuleEntity>> getStudentAssignments(String studentId) =>
      remote.getStudentAssignments(studentId);

  @override
  Future<List<TeacherAssignmentEntity>> getTeacherAssignments({String status = 'PENDING,IN_PROGRESS'}) =>
      remote.getTeacherAssignments(status: status);

  @override
  Future<List<PendingDiagnosisEntity>> getPendingDiagnoses({int limit = 50}) =>
      remote.getPendingDiagnoses(limit: limit);

  @override
  Future<LabelResultEntity> labelDiagnosis({
    required String diagnosisId,
    required String confirmedSubtype,
    required String confirmedSeverity,
    required String confirmedRiskLevel,
    String? notes,
  }) => remote.labelDiagnosis(
    diagnosisId: diagnosisId,
    confirmedSubtype: confirmedSubtype,
    confirmedSeverity: confirmedSeverity,
    confirmedRiskLevel: confirmedRiskLevel,
    notes: notes,
  );

  @override
  Future<List<CalendarioEntryEntity>> getCalendario({bool soloVencidos = true}) =>
      remote.getCalendario(soloVencidos: soloVencidos);
}
