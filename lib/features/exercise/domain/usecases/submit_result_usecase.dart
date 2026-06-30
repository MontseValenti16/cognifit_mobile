import '../entities/exercise_entity.dart';
import '../repositories/exercise_repository.dart';
class SubmitResultUseCase {
  final ExerciseRepository repository;
  const SubmitResultUseCase(this.repository);
  Future<void> call(ExerciseResultEntity result) => repository.submitResult(result);
}
