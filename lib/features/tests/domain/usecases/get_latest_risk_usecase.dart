import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';
class GetLatestRiskUseCase {
  final ScreeningRepository repository;
  const GetLatestRiskUseCase(this.repository);
  Future<DiagnosisEntity?> call(String studentId) => repository.getLatestRisk(studentId);
}
