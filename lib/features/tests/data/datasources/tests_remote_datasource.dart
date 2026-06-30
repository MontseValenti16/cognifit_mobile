import '../../domain/entities/test_entity.dart';

abstract class TestsRemoteDataSource {
  Future<List<TestEntity>> getTests({String? query});
  Future<List<AssignableStudentEntity>> getAssignableStudents(String testId);
  Future<void> assignTest(AssignTestParams params);
}

class TestsRemoteDataSourceImpl implements TestsRemoteDataSource {
  static const _allTests = [
    TestEntity(
      id: 't1',
      title: 'Cuestionario de Observación',
      categoryLabel: 'TAMIZAJE RÁPIDO',
      difficulty: TestDifficulty.basic,
      category: TestCategory.screening,
      exercisesCount: 12,
    ),
    TestEntity(
      id: 't2',
      title: 'Conciencia Fonológica',
      categoryLabel: 'PRUEBAS FONOLÓGICAS',
      difficulty: TestDifficulty.mild,
      category: TestCategory.phonological,
      exercisesCount: 15,
    ),
    TestEntity(
      id: 't3',
      title: 'Lectura de Pseudopalabras',
      categoryLabel: 'PRUEBAS FONOLÓGICAS',
      difficulty: TestDifficulty.moderate,
      category: TestCategory.phonological,
      exercisesCount: 20,
    ),
    TestEntity(
      id: 't4',
      title: 'Dictado Inteligente por voz',
      categoryLabel: 'PRUEBAS FONOLÓGICAS',
      difficulty: TestDifficulty.severe,
      category: TestCategory.phonological,
      exercisesCount: 18,
    ),
  ];

  static const _students = [
    AssignableStudentEntity(
      id: 's1',
      fullName: 'Luis Ramírez',
      grade: '3°A',
      initials: 'LR',
    ),
    AssignableStudentEntity(
      id: 's2',
      fullName: 'Ana Sofía Martínez',
      grade: '2°B',
      initials: 'AM',
    ),
    AssignableStudentEntity(
      id: 's3',
      fullName: 'Carlos Pérez',
      grade: '3°A',
      initials: 'CP',
    ),
  ];

  @override
  Future<List<TestEntity>> getTests({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: GET /tests?q=query
    if (query == null || query.isEmpty) return _allTests;
    return _allTests
        .where((t) => t.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<AssignableStudentEntity>> getAssignableStudents(
    String testId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: GET /tests/:id/assignable-students
    return _students;
  }

  @override
  Future<void> assignTest(AssignTestParams params) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: POST /tests/assign
  }
}
