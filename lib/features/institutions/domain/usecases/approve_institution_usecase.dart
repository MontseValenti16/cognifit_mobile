import '../entities/institution_entity.dart';
import '../repositories/institution_repository.dart';

class ApproveInstitutionUseCase {
  final InstitutionRepository repository;
  const ApproveInstitutionUseCase(this.repository);

  Future<InstitutionEntity> call(String institutionId) => repository.approve(institutionId);
}
