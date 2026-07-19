import '../../../../core/network/api_client.dart';
import '../models/intervention_model.dart';

abstract class InterventionRemoteDataSource {
  Future<ActivePathModel> getActivePath(String studentId);
  Future<NextExerciseModel> nextExercise({
    required String studentId,
    required List<String> currentRoute,
    required List<Map<String, dynamic>> sessionHistory,
  });

  /// Ejercicios de comprensión del grado del alumno. No lleva parámetro de
  /// grado: lo resuelve el servidor a partir del alumno.
  Future<ComprehensionTrackModel> getComprehensionTrack(String studentId);

  /// Detalle completo de un ejercicio (texto e ítems). En la vía diagnóstica
  /// el detalle viene incrustado en `next-exercise`; la vía de comprensión lo
  /// pide por separado, al abrir cada ejercicio.
  Future<ExerciseDetailModel> getExerciseDetail(String exerciseId);
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

  @override
  Future<ComprehensionTrackModel> getComprehensionTrack(String studentId) async {
    final json = await client.get('/intervention/students/$studentId/comprehension');
    return ComprehensionTrackModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<ExerciseDetailModel> getExerciseDetail(String exerciseId) async {
    final json = await client.get('/intervention/exercises/$exerciseId');
    return ExerciseDetailModel.fromJson(json as Map<String, dynamic>);
  }
}
