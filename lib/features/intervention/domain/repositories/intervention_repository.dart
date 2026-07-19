import '../entities/intervention_entity.dart';

abstract class InterventionRepository {
  Future<ActivePathEntity> getActivePath(String studentId);
  Future<NextExerciseEntity> nextExercise({
    required String studentId,
    required List<String> currentRoute,
    required List<Map<String, dynamic>> sessionHistory,
  });

  /// Catálogo de comprensión del grado del alumno (vía universal). No depende
  /// del diagnóstico: cualquier alumno del grado puede hacerlos.
  Future<ComprehensionTrackEntity> getComprehensionTrack(String studentId);

  /// Detalle completo de un ejercicio: texto e ítems.
  Future<ExerciseDetailEntity> getExerciseDetail(String exerciseId);
}
