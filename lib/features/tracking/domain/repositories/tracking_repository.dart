import '../entities/tracking_entity.dart';

abstract class TrackingRepository {
  Future<LearningCurveEntity> getLearningCurve(String studentId);
  Future<StudentMetricsEntity> getStudentMetrics(String studentId);
  Future<GroupMetricsEntity> getGroupMetrics(String groupId);
  Future<List<AlertEntity>> getAlerts({bool onlyUnread = false});
  Future<AlertEntity> markAlertRead(String alertId);
}
