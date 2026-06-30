import '../../../../core/network/api_client.dart';
import '../models/tracking_model.dart';

abstract class TrackingRemoteDataSource {
  Future<LearningCurveModel> getLearningCurve(String studentId);
  Future<StudentMetricsModel> getStudentMetrics(String studentId);
  Future<GroupMetricsModel> getGroupMetrics(String groupId);
  Future<List<AlertModel>> getAlerts({bool onlyUnread = false});
  Future<AlertModel> markAlertRead(String alertId);
}

/// Maps to TRACKING section of API_UI_GUIA.md
class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  final ApiClient client;
  const TrackingRemoteDataSourceImpl(this.client);

  @override
  Future<LearningCurveModel> getLearningCurve(String studentId) async {
    final json = await client.get('/tracking/students/$studentId/learning-curve');
    return LearningCurveModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<StudentMetricsModel> getStudentMetrics(String studentId) async {
    final json = await client.get('/tracking/students/$studentId/metrics');
    return StudentMetricsModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<GroupMetricsModel> getGroupMetrics(String groupId) async {
    final json = await client.get('/tracking/groups/$groupId/metrics');
    return GroupMetricsModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<AlertModel>> getAlerts({bool onlyUnread = false}) async {
    final json = await client.get('/tracking/alerts', query: onlyUnread ? {'only_unread': true} : null);
    return (json as List).map((e) => AlertModel.fromJson(e)).toList();
  }

  @override
  Future<AlertModel> markAlertRead(String alertId) async {
    final json = await client.post('/tracking/alerts/$alertId/read');
    return AlertModel.fromJson(json as Map<String, dynamic>);
  }
}
