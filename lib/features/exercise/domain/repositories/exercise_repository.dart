import '../entities/exercise_entity.dart';
abstract class ExerciseRepository {
  Future<List<ExerciseEntity>> getExercises(String testId);
  Future<void> submitResult(ExerciseResultEntity result);
}
