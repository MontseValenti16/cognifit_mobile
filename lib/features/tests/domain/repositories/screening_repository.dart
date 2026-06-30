import '../entities/screening_entity.dart';

abstract class ScreeningRepository {
  Future<List<TeacherItemEntity>> getTeacherItems();
  Future<TeacherResultEntity> submitTeacherResults(String studentId, List<TeacherAnswer> answers);
  Future<List<ScreeningModuleEntity>> getCatalog();
  Future<AssignmentResultEntity> assignBattery(String studentId, double teacherScore, List<RiskFlag> riskFlags);
  Future<ScreeningSessionEntity> openSession({
    required String assignmentId,
    required String moduleCode,
    String? deviceId,
    String? appVersion,
  });
  Future<SessionItemsResultEntity> getSessionItems(String sessionId);
  Future<List<ResponseResultEntity>> submitResponses(String sessionId, List<ItemResponseSubmission> responses);
  Future<DiagnosisEntity> diagnose(String sessionId);
  Future<DiagnosisEntity?> getLatestRisk(String studentId);
}
