import 'package:flutter_test/flutter_test.dart';
import 'package:cognifit_mobile/features/institutions/domain/repositories/institution_repository.dart';
import 'package:cognifit_mobile/features/institutions/domain/usecases/reject_institution_usecase.dart';

class _FakeRepo implements InstitutionRepository {
  String? idRecibido;
  String? motivoRecibido;
  @override
  Future<void> reject(String id, {String? reason}) async {
    idRecibido = id; motivoRecibido = reason;
  }
  @override
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  test('el usecase pasa id y motivo al repositorio', () async {
    final repo = _FakeRepo();
    await RejectInstitutionUseCase(repo)('inst-1', reason: 'Datos duplicados');
    expect(repo.idRecibido, 'inst-1');
    expect(repo.motivoRecibido, 'Datos duplicados');
  });
}
