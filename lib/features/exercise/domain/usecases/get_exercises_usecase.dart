import '../entities/exercise_entity.dart';
import '../repositories/exercise_repository.dart';
class GetExercisesUseCase {
  final ExerciseRepository repository;
  const GetExercisesUseCase(this.repository);
  Future<List<ExerciseEntity>> call(String testId) => repository.getExercises(testId);
}
