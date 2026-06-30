import '../../domain/entities/screening_entity.dart';
import '../../domain/repositories/screening_repository.dart';
import '../datasources/screening_remote_datasource.dart';

class ScreeningRepositoryImpl implements ScreeningRepository {
  final ScreeningRemoteDataSource remote;
  const ScreeningRepositoryImpl(this.remote);

  @override
  Future<List<TeacherItemEntity>> getTeacherItems() => remote.getTeacherItems();

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
  Future<List<ResponseResultEntity>> submitResponses(String sessionId, List<ItemResponseSubmission> responses) =>
      remote.submitResponses(sessionId, responses);

  @override
  Future<DiagnosisEntity> diagnose(String sessionId) => remote.diagnose(sessionId);

  @override
  Future<DiagnosisEntity?> getLatestRisk(String studentId) => remote.getLatestRisk(studentId);
}
