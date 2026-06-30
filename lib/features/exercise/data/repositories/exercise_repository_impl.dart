import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../datasources/exercise_remote_datasource.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseRemoteDataSource remote;
  const ExerciseRepositoryImpl(this.remote);
  @override
  Future<List<ExerciseEntity>> getExercises(String testId) => remote.getExercises(testId);
  @override
  Future<void> submitResult(ExerciseResultEntity result) => remote.submitResult(result);
}
