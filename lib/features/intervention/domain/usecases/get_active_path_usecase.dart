import '../entities/intervention_entity.dart';
import '../repositories/intervention_repository.dart';

class GetActivePathUseCase {
  final InterventionRepository repository;
  const GetActivePathUseCase(this.repository);
  Future<ActivePathEntity> call(String studentId) => repository.getActivePath(studentId);
}
