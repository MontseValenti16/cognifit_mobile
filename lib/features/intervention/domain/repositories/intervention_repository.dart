import '../entities/intervention_entity.dart';

abstract class InterventionRepository {
  Future<ActivePathEntity> getActivePath(String studentId);
  Future<NextExerciseEntity> nextExercise({
    required String studentId,
    required List<String> currentRoute,
    required List<Map<String, dynamic>> sessionHistory,
  });
}
