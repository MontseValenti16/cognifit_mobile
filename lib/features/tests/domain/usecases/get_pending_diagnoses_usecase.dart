import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';

class GetPendingDiagnosesUseCase {
  final ScreeningRepository repository;
  const GetPendingDiagnosesUseCase(this.repository);

  Future<List<PendingDiagnosisEntity>> call({int limit = 50}) =>
      repository.getPendingDiagnoses(limit: limit);
}
