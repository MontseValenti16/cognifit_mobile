import '../entities/test_entity.dart';
import '../repositories/tests_repository.dart';
class AssignTestUseCase {
  final TestsRepository repository;
  const AssignTestUseCase(this.repository);
  Future<void> call(AssignTestParams params) => repository.assignTest(params);
}
