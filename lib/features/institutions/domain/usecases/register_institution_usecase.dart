import '../entities/institution_entity.dart';
import '../repositories/institution_repository.dart';

class RegisterInstitutionUseCase {
  final InstitutionRepository repository;
  const RegisterInstitutionUseCase(this.repository);

  Future<void> call(RegisterInstitutionParams params) => repository.register(params);
}
