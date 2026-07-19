import '../../domain/entities/intervention_entity.dart';
import '../../domain/repositories/intervention_repository.dart';
import '../datasources/intervention_remote_datasource.dart';

class InterventionRepositoryImpl implements InterventionRepository {
  final InterventionRemoteDataSource remote;
  const InterventionRepositoryImpl(this.remote);

  @override
  Future<ActivePathEntity> getActivePath(String studentId) =>
      remote.getActivePath(studentId);

  @override
  Future<NextExerciseEntity> nextExercise({
    required String studentId,
    required List<String> currentRoute,
    required List<Map<String, dynamic>> sessionHistory,
  }) => remote.nextExercise(
    studentId: studentId,
    currentRoute: currentRoute,
    sessionHistory: sessionHistory,
  );

  @override
  Future<ComprehensionTrackEntity> getComprehensionTrack(String studentId) =>
      remote.getComprehensionTrack(studentId);

  @override
  Future<ExerciseDetailEntity> getExerciseDetail(String exerciseId) =>
      remote.getExerciseDetail(exerciseId);
}
