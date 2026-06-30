import '../entities/test_entity.dart';
abstract class TestsRepository {
  Future<List<TestEntity>> getTests({String? query});
  Future<List<AssignableStudentEntity>> getAssignableStudents(String testId);
  Future<void> assignTest(AssignTestParams params);
}
