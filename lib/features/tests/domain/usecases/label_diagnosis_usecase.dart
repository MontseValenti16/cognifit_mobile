import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';

class LabelDiagnosisUseCase {
  final ScreeningRepository repository;
  const LabelDiagnosisUseCase(this.repository);

  Future<LabelResultEntity> call({
    required String diagnosisId,
    required String confirmedSubtype,
    required String confirmedSeverity,
    required String confirmedRiskLevel,
    String? notes,
  }) => repository.labelDiagnosis(
    diagnosisId: diagnosisId,
    confirmedSubtype: confirmedSubtype,
    confirmedSeverity: confirmedSeverity,
    confirmedRiskLevel: confirmedRiskLevel,
    notes: notes,
  );
}
