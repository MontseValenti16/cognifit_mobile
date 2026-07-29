
class TeacherItemEntity {
  final String itemCode;
  final String prompt;
  final double weight;
  final List<String> tags;
  final String? sourceNote;
  final Map<String, double> scale;

  final String categoria;

  final List<int> ciclos;

  const TeacherItemEntity({
    required this.itemCode,
    required this.prompt,
    required this.weight,
    required this.tags,
    this.sourceNote,
    required this.scale,
    this.categoria = 'RIESGO',
    this.ciclos = const [1, 2, 3],
  });
}

class TeacherAnswer {
  final String itemCode;
  final double value;
  const TeacherAnswer({required this.itemCode, required this.value});
}

class RiskFlag {
  final String flag;
  final String level;
  const RiskFlag({required this.flag, required this.level});
}

class ClinicalAlert {
  final String itemCode;
  final List<String> tags;
  final String certeza;
  const ClinicalAlert({required this.itemCode, required this.tags, required this.certeza});
}

class TeacherResultEntity {
  final String id;
  final String studentId;
  final double score;
  final String batteryMode;
  final List<RiskFlag> riskFlags;
  final List<String> enabledModuleCodes;

  final List<ClinicalAlert> alertasClinicas;

  final bool requiereDescartarSensorial;

  final double? indiceDiscrepancia;

  const TeacherResultEntity({
    required this.id,
    required this.studentId,
    required this.score,
    required this.batteryMode,
    required this.riskFlags,
    required this.enabledModuleCodes,
    this.alertasClinicas = const [],
    this.requiereDescartarSensorial = false,
    this.indiceDiscrepancia,
  });
}

class ScreeningModuleEntity {
  final int moduleNumber;
  final String moduleCode;
  final String name;
  final bool usaTts;
  final bool usaStt;

  const ScreeningModuleEntity({
    required this.moduleNumber,
    required this.moduleCode,
    required this.name,
    required this.usaTts,
    required this.usaStt,
  });
}

class AssignmentEntity {
  final String id;
  final String studentId;
  final String testId;
  final String status;
  final String assignedAt;
  final String moduleCode;

  const AssignmentEntity({
    required this.id,
    required this.studentId,
    required this.testId,
    required this.status,
    required this.assignedAt,
    required this.moduleCode,
  });
}

class AssignmentResultEntity {
  final List<String> enabledModuleCodes;
  final List<AssignmentEntity> assignments;
  const AssignmentResultEntity({required this.enabledModuleCodes, required this.assignments});
}

class PendingModuleEntity {
  final String assignmentId;
  final String moduleCode;
  final String moduleName;
  final String status;

  const PendingModuleEntity({
    required this.assignmentId,
    required this.moduleCode,
    required this.moduleName,
    required this.status,
  });
}

class ScreeningSessionEntity {
  final String id;
  final String assignmentId;
  final String moduleId;
  final String sessionStatus;
  final String startedAt;
  final String? deviceId;
  final String? appVersion;

  const ScreeningSessionEntity({
    required this.id,
    required this.assignmentId,
    required this.moduleId,
    required this.sessionStatus,
    required this.startedAt,
    this.deviceId,
    this.appVersion,
  });
}

class SessionItemEntity {
  final String itemId;
  final int itemOrder;
  final String itemCode;
  final String stimulusText;
  final String? stimulusAudioUrl;
  final String? expectedResponse;
  final String itemKind;
  final int difficulty;
  final List<String> tags;
  final bool isPractice;
  final String moduleCode;
  final String moduleTitle;
  final List<String> inputModes;

  const SessionItemEntity({
    required this.itemId,
    required this.itemOrder,
    required this.itemCode,
    required this.stimulusText,
    this.stimulusAudioUrl,
    this.expectedResponse,
    required this.itemKind,
    required this.difficulty,
    required this.tags,
    required this.isPractice,
    required this.moduleCode,
    required this.moduleTitle,
    required this.inputModes,
  });
}

class SessionItemsResultEntity {
  final String sessionId;
  final int totalItems;
  final List<SessionItemEntity> items;
  const SessionItemsResultEntity({required this.sessionId, required this.totalItems, required this.items});
}

class ItemResponseSubmission {
  final String itemId;
  final String rawResponse;

  final int responseTimeMs;
  final String captureModality;
  final double? sttConfidence;
  final String? responseAudioUrl;

  final ResponseTimingDetail? timingDetail;

  const ItemResponseSubmission({
    required this.itemId,
    required this.rawResponse,
    required this.responseTimeMs,
    required this.captureModality,
    this.sttConfidence,
    this.responseAudioUrl,
    this.timingDetail,
  });
}

class ResponseTimingDetail {
  final int totalMs;
  final int ttsMs;
  final int backgroundMs;
  final int netMs;
  final int stimulusChars;
  final int stimulusWords;
  final int difficulty;

  const ResponseTimingDetail({
    required this.totalMs,
    required this.ttsMs,
    required this.backgroundMs,
    required this.netMs,
    required this.stimulusChars,
    required this.stimulusWords,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
        'total_ms': totalMs,
        'tts_ms': ttsMs,
        'background_ms': backgroundMs,
        'net_ms': netMs,
        'stimulus_chars': stimulusChars,
        'stimulus_words': stimulusWords,
        'difficulty': difficulty,
      };
}

class ResponseResultEntity {
  final String id;
  final String itemId;
  final String rawResponse;
  final String normalizedResponse;
  final bool isCorrect;
  final List<String> errorTags;

  const ResponseResultEntity({
    required this.id,
    required this.itemId,
    required this.rawResponse,
    required this.normalizedResponse,
    required this.isCorrect,
    required this.errorTags,
  });
}

class TedePercentil {
  final int? percentilPorGrado;
  final int? percentilPorEdad;
  final int puntajeEscalaTede;
  final bool escalado;
  const TedePercentil({
    this.percentilPorGrado,
    this.percentilPorEdad,
    required this.puntajeEscalaTede,
    this.escalado = false,
  });

  static TedePercentil? fromJson(Map<String, dynamic>? j) {
    if (j == null) return null;
    return TedePercentil(
      percentilPorGrado: (j['percentil_por_grado'] as num?)?.toInt(),
      percentilPorEdad: (j['percentil_por_edad'] as num?)?.toInt(),
      puntajeEscalaTede: (j['puntaje_escala_tede'] as num?)?.toInt() ?? 0,
      escalado: j['escalado'] as bool? ?? false,
    );
  }
}

class DiagnosisEntity {
  final String id;
  final String studentId;
  final String assignmentId;
  final String subtype;
  final String plnSubtype;
  final String severity;
  final String plnSeverity;
  final double riskProbability;
  final String riskLevel;
  final List<String> mainErrorCodes;
  final List<String> recommendedRoute;
  final String recommendationReason;
  final String diagnosedAt;
  final String? modelVersion;
  final String? plnSource;

  final TedePercentil? tedeNivelLector;

  final TedePercentil? tedeErroresEspecificos;

  const DiagnosisEntity({
    required this.id,
    required this.studentId,
    required this.assignmentId,
    required this.subtype,
    required this.plnSubtype,
    required this.severity,
    required this.plnSeverity,
    required this.riskProbability,
    required this.riskLevel,
    required this.mainErrorCodes,
    required this.recommendedRoute,
    required this.recommendationReason,
    required this.diagnosedAt,
    this.modelVersion,
    this.plnSource,
    this.tedeNivelLector,
    this.tedeErroresEspecificos,
  });
}

class TeacherAssignmentEntity {
  final String id;
  final String studentId;
  final String studentName;
  final String moduleCode;
  final String moduleName;
  final String status;
  final String assignedAt;
  final String? completedAt;

  const TeacherAssignmentEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.moduleCode,
    required this.moduleName,
    required this.status,
    required this.assignedAt,
    this.completedAt,
  });

  bool get isPending => status == 'PENDING' || status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
}

class PendingDiagnosisEntity {
  final String id;
  final String autoSubtype;
  final String autoSeverity;
  final String autoRiskLevel;
  final double riskProbability;
  final List<String> mainErrorCodes;
  final Map<String, dynamic> errorBreakdown;
  final String plnSource;
  final String diagnosedAt;
  final String studentName;
  final int? grade;

  const PendingDiagnosisEntity({
    required this.id,
    required this.autoSubtype,
    required this.autoSeverity,
    required this.autoRiskLevel,
    required this.riskProbability,
    required this.mainErrorCodes,
    required this.errorBreakdown,
    required this.plnSource,
    required this.diagnosedAt,
    required this.studentName,
    this.grade,
  });

  String get subtypeLabel => _subtypeLabel(autoSubtype);
  String get severityLabel => _severityLabel(autoSeverity);

  static String _subtypeLabel(String v) => switch (v) {
    'PHONOLOGICAL'   => 'Fonológico',
    'VISUAL_SURFACE' => 'Visual/Superficial',
    'MIXED'          => 'Mixto',
    'FLUENCY'        => 'Fluidez',
    'COMPREHENSION'  => 'Comprensión',
    'RISK_ONLY'      => 'Solo riesgo',
    'NO_DYSLEXIA'    => 'Sin riesgo',
    _                => v,
  };

  static String _severityLabel(String v) => switch (v) {
    'MILD'       => 'Leve',
    'MODERATE'   => 'Moderado',
    'SEVERE'     => 'Severo',
    'NONE'       => 'Sin riesgo',
    'VERY_SEVERE'=> 'Muy severo',
    _            => v,
  };
}

class CalendarioEntryEntity {
  final String studentId;
  final String studentName;
  final int grade;
  final String queToca;
  final String? ultMonitoreo;
  final String? ultBateria;
  final bool sinLineaBase;
  const CalendarioEntryEntity({
    required this.studentId,
    required this.studentName,
    required this.grade,
    required this.queToca,
    this.ultMonitoreo,
    this.ultBateria,
    this.sinLineaBase = false,
  });
}

class LabelResultEntity {
  final String id;
  final String diagnosisId;
  final String confirmedSubtype;
  final String confirmedSeverity;
  final String confirmedRiskLevel;
  final String labeledAt;

  const LabelResultEntity({
    required this.id,
    required this.diagnosisId,
    required this.confirmedSubtype,
    required this.confirmedSeverity,
    required this.confirmedRiskLevel,
    required this.labeledAt,
  });
}
