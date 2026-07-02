import 'package:flutter/foundation.dart';
import '../../../../features/tests/domain/entities/screening_entity.dart';
import '../../../../features/tests/domain/usecases/get_pending_diagnoses_usecase.dart';
import '../../../../features/tests/domain/usecases/label_diagnosis_usecase.dart';

class SpecialistViewModel extends ChangeNotifier {
  final GetPendingDiagnosesUseCase _getPending;
  final LabelDiagnosisUseCase _label;

  SpecialistViewModel({
    required GetPendingDiagnosesUseCase getPending,
    required LabelDiagnosisUseCase label,
  })  : _getPending = getPending,
        _label = label;

  bool _isLoading = false;
  String? _error;
  List<PendingDiagnosisEntity> _pending = [];
  // IDs de diagnósticos etiquetados en esta sesión (para filtrarlos de la lista)
  final Set<String> _labeled = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PendingDiagnosisEntity> get pending =>
      _pending.where((d) => !_labeled.contains(d.id)).toList();
  int get totalLabeled => _labeled.length;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _pending = await _getPending();
    } catch (e) {
      _error = 'No se pudieron cargar los diagnósticos: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Confirma el diagnóstico automático tal cual (sin corrección).
  Future<bool> confirm(PendingDiagnosisEntity d, {String? notes}) =>
      _submitLabel(
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
      _labeled.add(diagnosisId);
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('labelDiagnosis error: $e');
      return false;
    }
  }
}
