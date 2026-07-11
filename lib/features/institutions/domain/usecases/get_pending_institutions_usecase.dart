import '../entities/institution_entity.dart';
import '../repositories/institution_repository.dart';

class GetPendingInstitutionsUseCase {
  final InstitutionRepository repository;
  const GetPendingInstitutionsUseCase(this.repository);

  Future<List<InstitutionEntity>> call() => repository.getPending();
}
