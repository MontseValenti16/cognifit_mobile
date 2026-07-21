import '../../domain/entities/screening_entity.dart';

class TeacherItemModel extends TeacherItemEntity {
  const TeacherItemModel({
    required super.itemCode, required super.prompt, required super.weight,
    required super.tags, super.sourceNote, required super.scale,
    super.categoria, super.ciclos,
  });

  factory TeacherItemModel.fromJson(Map<String, dynamic> j) => TeacherItemModel(
    itemCode: j['item_code'] as String,
    prompt: j['prompt'] as String,
    weight: (j['weight'] as num?)?.toDouble() ?? 1.0,
    tags: (j['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    sourceNote: j['source_note'] as String?,
    scale: _parseScale(j['scale']),
    categoria: j['categoria'] as String? ?? 'RIESGO',
    ciclos: (j['ciclos'] as List?)?.map((e) => (e as num).toInt()).toList()
        ?? const [1, 2, 3],
  );

  // API returns scale as [{label, value}] list OR as {label: value} map.
  static Map<String, double> _parseScale(dynamic raw) {
    if (raw is List) {
      return {
        for (final e in raw)
          (e as Map)['label'].toString(): ((e)['value'] as num).toDouble()
      };
    }
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
    }
    return const {'Nunca': 0, 'A veces': 0.5, 'Frecuente': 1};
  }
}

class TeacherResultModel extends TeacherResultEntity {
  const TeacherResultModel({
    required super.id, required super.studentId, required super.score,
    required super.batteryMode, required super.riskFlags, required super.enabledModuleCodes,
    super.alertasClinicas,
    super.requiereDescartarSensorial,
    super.indiceDiscrepancia,
  });

  factory TeacherResultModel.fromJson(Map<String, dynamic> j) => TeacherResultModel(
    id: j['id'].toString(),
    studentId: j['student_id'].toString(),
    score: (j['score'] as num).toDouble(),
    batteryMode: j['battery_mode'] as String? ?? 'FULL',
    // risk_flags from API: {item_code, tags, value} — map to {flag, level}
    riskFlags: (j['risk_flags'] as List? ?? []).map((f) {
      final m = f as Map;
      final code = m['flag'] ?? m['item_code'] ?? '';
      final val = (m['value'] as num?)?.toDouble() ?? 0.0;
      final level = m['level'] as String? ?? (val >= 1.0 ? 'high' : val >= 0.5 ? 'medium' : 'low');
      return RiskFlag(flag: code.toString(), level: level);
    }).toList(),
    enabledModuleCodes: (j['enabled_module_codes'] as List? ?? []).map((e) => e.toString()).toList(),
    alertasClinicas: (j['alertas_clinicas'] as List? ?? []).map((a) {
      final m = a as Map<String, dynamic>;
      return ClinicalAlert(
        itemCode: m['item_code'] as String? ?? '',
        tags: (m['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        certeza: m['certeza'] as String? ?? 'confirmado',
      );
    }).toList(),
    requiereDescartarSensorial: j['requiere_descartar_sensorial'] as bool? ?? false,
    indiceDiscrepancia: (j['indice_discrepancia'] as num?)?.toDouble(),
  );
}

class ScreeningModuleModel extends ScreeningModuleEntity {
  const ScreeningModuleModel({
    required super.moduleNumber, required super.moduleCode, required super.name,
    required super.usaTts, required super.usaStt,
  });

  factory ScreeningModuleModel.fromJson(Map<String, dynamic> j) => ScreeningModuleModel(
    moduleNumber: j['module_number'] as int? ?? 0,
    moduleCode: j['module_code'] as String,
    // v_battery_catalog returns 'title'; some seeds use 'name' — try both
    name: (j['name'] ?? j['title'] ?? j['module_code']) as String,
    usaTts: j['usa_tts'] as bool? ?? j['use_tts'] as bool? ?? false,
    usaStt: j['usa_stt'] as bool? ?? j['use_stt'] as bool? ?? false,
  );
}

class AssignmentModel extends AssignmentEntity {
  const AssignmentModel({
    required super.id, required super.studentId, required super.testId,
    required super.status, required super.assignedAt, required super.moduleCode,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> j) => AssignmentModel(
    id: j['id'] as String,
    studentId: j['student_id'] as String,
    testId: j['test_id'] as String? ?? '',
    status: j['status'] as String? ?? 'PENDING',
    assignedAt: j['assigned_at'] as String? ?? '',
    moduleCode: j['module_code'] as String? ?? '',
  );
}

class AssignmentResultModel extends AssignmentResultEntity {
  const AssignmentResultModel({required super.enabledModuleCodes, required super.assignments});

  factory AssignmentResultModel.fromJson(Map<String, dynamic> j) => AssignmentResultModel(
    enabledModuleCodes: (j['enabled_module_codes'] as List? ?? []).map((e) => e.toString()).toList(),
    assignments: (j['assignments'] as List? ?? []).map((a) => AssignmentModel.fromJson(a)).toList(),
  );
}

class PendingModuleModel extends PendingModuleEntity {
  const PendingModuleModel({
    required super.assignmentId, required super.moduleCode,
    required super.moduleName, required super.status,
  });

  factory PendingModuleModel.fromJson(Map<String, dynamic> j) => PendingModuleModel(
    assignmentId: j['id'] as String,
    moduleCode: j['module_code'] as String? ?? '',
    moduleName: j['module_name'] as String? ?? '',
    status: j['status'] as String? ?? 'PENDING',
  );
}

class ScreeningSessionModel extends ScreeningSessionEntity {
  const ScreeningSessionModel({
    required super.id, required super.assignmentId, required super.moduleId,
    required super.sessionStatus, required super.startedAt, super.deviceId, super.appVersion,
  });

  factory ScreeningSessionModel.fromJson(Map<String, dynamic> j) => ScreeningSessionModel(
    id: j['id'] as String,
    assignmentId: j['assignment_id'] as String,
    moduleId: j['module_id'] as String? ?? '',
    sessionStatus: j['session_status'] as String? ?? 'IN_PROGRESS',
    startedAt: j['started_at'] as String? ?? '',
    deviceId: j['device_id'] as String?,
    appVersion: j['app_version'] as String?,
  );
}

class SessionItemModel extends SessionItemEntity {
  const SessionItemModel({
    required super.itemId, required super.itemOrder, required super.itemCode,
    required super.stimulusText, super.stimulusAudioUrl, super.expectedResponse,
    required super.itemKind, required super.difficulty, required super.tags,
    required super.isPractice, required super.moduleCode, required super.moduleTitle,
    required super.inputModes,
  });

  factory SessionItemModel.fromJson(Map<String, dynamic> j) => SessionItemModel(
    itemId: j['item_id'] as String,
    itemOrder: j['item_order'] as int? ?? 0,
    itemCode: j['item_code'] as String? ?? '',
    stimulusText: j['stimulus_text'] as String? ?? '',
    stimulusAudioUrl: j['stimulus_audio_url'] as String?,
    expectedResponse: j['expected_response'] as String?,
    itemKind: j['item_kind'] as String? ?? '',
    difficulty: j['difficulty'] as int? ?? 1,
    tags: (j['tags'] as List? ?? []).map((e) => e.toString()).toList(),
    isPractice: j['is_practice'] as bool? ?? false,
    moduleCode: j['module_code'] as String? ?? '',
    moduleTitle: j['module_title'] as String? ?? '',
    inputModes: (j['input_modes'] as List? ?? []).map((e) => e.toString()).toList(),
  );
}

class SessionItemsResultModel extends SessionItemsResultEntity {
  const SessionItemsResultModel({required super.sessionId, required super.totalItems, required super.items});

  factory SessionItemsResultModel.fromJson(Map<String, dynamic> j) => SessionItemsResultModel(
    sessionId: j['session_id'] as String,
    totalItems: j['total_items'] as int? ?? 0,
    items: (j['items'] as List? ?? []).map((i) => SessionItemModel.fromJson(i)).toList(),
  );
}

class ResponseResultModel extends ResponseResultEntity {
  const ResponseResultModel({
    required super.id, required super.itemId, required super.rawResponse,
    required super.normalizedResponse, required super.isCorrect, required super.errorTags,
  });

  factory ResponseResultModel.fromJson(Map<String, dynamic> j) => ResponseResultModel(
    id: j['id'] as String,
    itemId: j['item_id'] as String,
    rawResponse: j['raw_response'] as String? ?? '',
    normalizedResponse: j['normalized_response'] as String? ?? '',
    isCorrect: j['is_correct'] as bool? ?? false,
    errorTags: (j['error_tags'] as List? ?? []).map((e) => e.toString()).toList(),
  );
}

class DiagnosisModel extends DiagnosisEntity {
  const DiagnosisModel({
    required super.id, required super.studentId, required super.assignmentId,
    required super.subtype, required super.plnSubtype, required super.severity,
    required super.plnSeverity, required super.riskProbability, required super.riskLevel,
    required super.mainErrorCodes, required super.recommendedRoute,
    required super.recommendationReason, required super.diagnosedAt,
    super.modelVersion, super.plnSource,
    super.tedeNivelLector,
    super.tedeErroresEspecificos,
  });

  factory DiagnosisModel.fromJson(Map<String, dynamic> j) => DiagnosisModel(
    id: j['id'] as String? ?? '',
    studentId: j['student_id'] as String? ?? '',
    assignmentId: j['assignment_id'] as String? ?? '',
    subtype: j['subtype'] as String? ?? '',
    plnSubtype: j['pln_subtype'] as String? ?? 'sin_riesgo',
    severity: j['severity'] as String? ?? '',
    plnSeverity: j['pln_severity'] as String? ?? 'ninguna',
    riskProbability: (j['risk_probability'] as num?)?.toDouble() ?? 0.0,
    riskLevel: j['risk_level'] as String? ?? 'LOW',
    mainErrorCodes: (j['main_error_codes'] as List? ?? []).map((e) => e.toString()).toList(),
    recommendedRoute: (j['recommended_route'] as List? ?? []).map((e) => e.toString()).toList(),
    recommendationReason: j['recommendation_reason'] as String? ?? '',
    diagnosedAt: j['diagnosed_at'] as String? ?? '',
    modelVersion: j['model_version'] as String?,
    plnSource: j['pln_source'] as String?,
    tedeNivelLector: TedePercentil.fromJson(j['tede_nivel_lector'] as Map<String, dynamic>?),
    tedeErroresEspecificos: TedePercentil.fromJson(j['tede_errores_especificos'] as Map<String, dynamic>?),
  );
}

class TeacherAssignmentModel extends TeacherAssignmentEntity {
  const TeacherAssignmentModel({
    required super.id, required super.studentId, required super.studentName,
    required super.moduleCode, required super.moduleName,
    required super.status, required super.assignedAt, super.completedAt,
  });

  factory TeacherAssignmentModel.fromJson(Map<String, dynamic> j) => TeacherAssignmentModel(
    id: j['id'] as String? ?? '',
    studentId: j['student_id'] as String? ?? '',
    studentName: j['student_name'] as String? ?? '',
    moduleCode: j['module_code'] as String? ?? '',
    moduleName: j['module_name'] as String? ?? '',
    status: j['status'] as String? ?? 'PENDING',
    assignedAt: j['assigned_at'] as String? ?? '',
    completedAt: j['completed_at'] as String?,
  );
}

class PendingDiagnosisModel extends PendingDiagnosisEntity {
  const PendingDiagnosisModel({
    required super.id, required super.autoSubtype, required super.autoSeverity,
    required super.autoRiskLevel, required super.riskProbability,
    required super.mainErrorCodes, required super.errorBreakdown,
    required super.plnSource, required super.diagnosedAt,
    required super.studentName, super.grade,
  });

  factory PendingDiagnosisModel.fromJson(Map<String, dynamic> j) => PendingDiagnosisModel(
    id: j['id'] as String? ?? '',
    autoSubtype: j['auto_subtype'] as String? ?? '',
    autoSeverity: j['auto_severity'] as String? ?? '',
    autoRiskLevel: j['auto_risk_level'] as String? ?? 'LOW',
    riskProbability: (j['risk_probability'] as num?)?.toDouble() ?? 0.0,
    mainErrorCodes: (j['main_error_codes'] as List? ?? []).map((e) => e.toString()).toList(),
    errorBreakdown: (j['error_breakdown'] as Map<String, dynamic>?) ?? {},
    plnSource: j['pln_source'] as String? ?? 'rule',
    diagnosedAt: j['diagnosed_at'] as String? ?? '',
    studentName: j['student_name'] as String? ?? '',
    grade: j['grade'] as int?,
  );
}

class CalendarioEntryModel extends CalendarioEntryEntity {
  const CalendarioEntryModel({
    required super.studentId, required super.studentName, required super.grade,
    required super.queToca, super.ultMonitoreo, super.ultBateria, super.sinLineaBase,
  });

  factory CalendarioEntryModel.fromJson(Map<String, dynamic> j) => CalendarioEntryModel(
    studentId: j['student_id'].toString(),
    studentName: j['student_name'] as String? ?? '',
    grade: (j['grade'] as num?)?.toInt() ?? 0,
    queToca: j['que_toca'] as String? ?? 'AL_DIA',
    ultMonitoreo: j['ult_monitoreo'] as String?,
    ultBateria: j['ult_bateria'] as String?,
    sinLineaBase: j['sin_linea_base'] as bool? ?? false,
  );
}

class LabelResultModel extends LabelResultEntity {
  const LabelResultModel({
    required super.id, required super.diagnosisId,
    required super.confirmedSubtype, required super.confirmedSeverity,
    required super.confirmedRiskLevel, required super.labeledAt,
  });

  factory LabelResultModel.fromJson(Map<String, dynamic> j) => LabelResultModel(
    id: j['id'] as String? ?? '',
    diagnosisId: j['diagnosis_id'] as String? ?? '',
    confirmedSubtype: j['confirmed_subtype'] as String? ?? '',
    confirmedSeverity: j['confirmed_severity'] as String? ?? '',
    confirmedRiskLevel: j['confirmed_risk_level'] as String? ?? '',
    labeledAt: j['labeled_at'] as String? ?? '',
  );
}
