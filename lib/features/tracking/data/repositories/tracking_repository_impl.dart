import '../../domain/entities/tracking_entity.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/tracking_remote_datasource.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingRemoteDataSource remote;
  const TrackingRepositoryImpl(this.remote);

  @override
  Future<LearningCurveEntity> getLearningCurve(String studentId) => remote.getLearningCurve(studentId);
  @override
  Future<StudentMetricsEntity> getStudentMetrics(String studentId) => remote.getStudentMetrics(studentId);
  @override
  Future<GroupMetricsEntity> getGroupMetrics(String groupId) => remote.getGroupMetrics(groupId);
  @override
  Future<List<AlertEntity>> getAlerts({bool onlyUnread = false}) => remote.getAlerts(onlyUnread: onlyUnread);
  @override
  Future<AlertEntity> markAlertRead(String alertId) => remote.markAlertRead(alertId);
}
