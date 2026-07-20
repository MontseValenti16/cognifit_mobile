import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/tests/domain/entities/screening_entity.dart';
import 'package:cognifit_mobile/features/tests/domain/repositories/screening_repository.dart';
import 'package:cognifit_mobile/features/tests/domain/usecases/get_teacher_items_usecase.dart';

class _FakeRepo implements ScreeningRepository {
  int? gradeRecibido = -1;
  @override
  Future<List<TeacherItemEntity>> getTeacherItems({int? grade}) async {
    gradeRecibido = grade;
    return const [];
  }
  @override
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  test('el usecase pasa el grado al repositorio', () async {
    final repo = _FakeRepo();
    await GetTeacherItemsUseCase(repo)(grade: 4);
    expect(repo.gradeRecibido, 4);
  });
}
