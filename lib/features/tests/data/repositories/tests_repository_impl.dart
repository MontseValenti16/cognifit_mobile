import '../../domain/entities/test_entity.dart';
import '../../domain/repositories/tests_repository.dart';
import '../datasources/tests_remote_datasource.dart';

class TestsRepositoryImpl implements TestsRepository {
  final TestsRemoteDataSource remote;
  const TestsRepositoryImpl(this.remote);

  @override
  Future<List<TestEntity>> getTests({String? query}) => remote.getTests(query: query);
  @override
  Future<List<AssignableStudentEntity>> getAssignableStudents(String testId) => remote.getAssignableStudents(testId);
  @override
  Future<void> assignTest(AssignTestParams params) => remote.assignTest(params);
}
