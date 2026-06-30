import '../entities/test_entity.dart';
import '../repositories/tests_repository.dart';
class GetTestsUseCase {
  final TestsRepository repository;
  const GetTestsUseCase(this.repository);
  Future<List<TestEntity>> call({String? query}) => repository.getTests(query: query);
}
