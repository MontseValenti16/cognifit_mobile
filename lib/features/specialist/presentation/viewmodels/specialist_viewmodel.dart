import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/tests/di/tests_providers.dart';
import '../../../../features/tests/domain/entities/screening_entity.dart';
import '../../../../features/tests/domain/usecases/get_pending_diagnoses_usecase.dart';
import '../../../../features/tests/domain/usecases/label_diagnosis_usecase.dart';

class SpecialistData {
  final List<PendingDiagnosisEntity> pending;
  final int totalLabeled;
  const SpecialistData({this.pending = const [], this.totalLabeled = 0});
}

class SpecialistNotifier extends Notifier<AsyncValue<SpecialistData>> {
  late GetPendingDiagnosesUseCase _getPending;
  late LabelDiagnosisUseCase _label;

  @override
  AsyncValue<SpecialistData> build() {
    final repo = ref.watch(screeningRepositoryProvider);
    _getPending = GetPendingDiagnosesUseCase(repo);
    _label = LabelDiagnosisUseCase(repo);
    return const AsyncValue.loading();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final pending = await _getPending();
      state = AsyncValue.data(SpecialistData(pending: pending));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Confirma el diagnóstico automático tal cual (sin corrección).
  Future<bool> confirm(PendingDiagnosisEntity d, {String? notes}) => _submitLabel(
        diagnosisId: d.id,
        subtype: d.autoSubtype,
        severity: d.autoSeverity,
        riskLevel: d.autoRiskLevel,
        notes: notes,
      );

  /// Corrige el diagnóstico con los valores que eligió el especialista.
  Future<bool> correct({
    required String diagnosisId,
    required String subtype,
    required String severity,
    required String riskLevel,
    String? notes,
  }) => _submitLabel(
    diagnosisId: diagnosisId,
    subtype: subtype,
    severity: severity,
    riskLevel: riskLevel,
    notes: notes,
  );

  Future<bool> _submitLabel({
    required String diagnosisId,
    required String subtype,
    required String severity,
    required String riskLevel,
    String? notes,
  }) async {
    try {
      await _label(
        diagnosisId: diagnosisId,
        confirmedSubtype: subtype,
        confirmedSeverity: severity,
        confirmedRiskLevel: riskLevel,
        notes: notes,
      );
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data(SpecialistData(
          pending: current.pending.where((d) => d.id != diagnosisId).toList(),
          totalLabeled: current.totalLabeled + 1,
        ));
      }
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('labelDiagnosis error: $e');
      return false;
    }
  }
}

final specialistViewModelProvider = NotifierProvider<SpecialistNotifier, AsyncValue<SpecialistData>>(SpecialistNotifier.new);
