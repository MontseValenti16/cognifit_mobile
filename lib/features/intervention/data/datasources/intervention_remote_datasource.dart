import '../../../../core/network/api_client.dart';
import '../models/intervention_model.dart';

abstract class InterventionRemoteDataSource {
  Future<ActivePathModel> getActivePath(String studentId);
  Future<NextExerciseModel> nextExercise({
    required String studentId,
    required List<String> currentRoute,
    required List<Map<String, dynamic>> sessionHistory,
  });
}

class InterventionRemoteDataSourceImpl implements InterventionRemoteDataSource {
  final ApiClient client;
  const InterventionRemoteDataSourceImpl(this.client);

  @override
  Future<ActivePathModel> getActivePath(String studentId) async {
    final json = await client.get('/intervention/students/$studentId/active-path');
    return ActivePathModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<NextExerciseModel> nextExercise({
    required String studentId,
    required List<String> currentRoute,
    required List<Map<String, dynamic>> sessionHistory,
  }) async {
    final json = await client.post(
      '/intervention/students/$studentId/next-exercise',
      data: {
        'current_route': currentRoute,
        'session_history': sessionHistory,
      },
    );
    return NextExerciseModel.fromJson(json as Map<String, dynamic>);
  }
}
