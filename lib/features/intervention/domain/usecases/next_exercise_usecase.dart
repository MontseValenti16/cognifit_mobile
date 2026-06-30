import '../entities/intervention_entity.dart';
import '../repositories/intervention_repository.dart';

class NextExerciseUseCase {
  final InterventionRepository repository;
  const NextExerciseUseCase(this.repository);
  Future<NextExerciseEntity> call({
    required String studentId,
    required List<String> currentRoute,
    required List<Map<String, dynamic>> sessionHistory,
  }) => repository.nextExercise(
    studentId: studentId,
    currentRoute: currentRoute,
    sessionHistory: sessionHistory,
  );
}
