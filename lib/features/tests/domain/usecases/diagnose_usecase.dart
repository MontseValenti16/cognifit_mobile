import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';
class DiagnoseUseCase {
  final ScreeningRepository repository;
  const DiagnoseUseCase(this.repository);
  Future<DiagnosisEntity> call(String sessionId) => repository.diagnose(sessionId);
}
