import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';
class AssignBatteryUseCase {
  final ScreeningRepository repository;
  const AssignBatteryUseCase(this.repository);
  Future<AssignmentResultEntity> call(String studentId, double teacherScore, List<RiskFlag> riskFlags) =>
      repository.assignBattery(studentId, teacherScore, riskFlags);
}
