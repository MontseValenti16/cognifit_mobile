import '../entities/test_entity.dart';
import '../repositories/tests_repository.dart';
class GetAssignableStudentsUseCase {
  final TestsRepository repository;
  const GetAssignableStudentsUseCase(this.repository);
  Future<List<AssignableStudentEntity>> call(String testId) => repository.getAssignableStudents(testId);
}
