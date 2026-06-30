/// Domain models for the SCREENING flow (API_UI_GUIA section 4).
/// Flow: teacher-items → teacher-results → catalog → assignments →
///       sessions → sessions/items → sessions/responses → sessions/diagnose

// ── Teacher questionnaire (8 fixed questions) ──────────────────────────────────
class TeacherItemEntity {
  final String itemCode;
  final String prompt;
  final double weight;
  final List<String> tags;
  final String? sourceNote;
  /// scale e.g. {"Nunca":0, "A veces":0.5, "Frecuente":1}
  final Map<String, double> scale;

  const TeacherItemEntity({
    required this.itemCode,
    required this.prompt,
    required this.weight,
    required this.tags,
    this.sourceNote,
    required this.scale,
  });
}

class TeacherAnswer {
  final String itemCode;
  final double value; // 0 / 0.5 / 1
  const TeacherAnswer({required this.itemCode, required this.value});
}

class RiskFlag {
  final String flag;
  final String level; // low/medium/high (representative)
  const RiskFlag({required this.flag, required this.level});
}

class TeacherResultEntity {
  final String id;
  final String studentId;
  final double score; // 0–100
  final String batteryMode;
  final List<RiskFlag> riskFlags;
  final List<String> enabledModuleCodes;

  const TeacherResultEntity({
    required this.id,
    required this.studentId,
    required this.score,
    required this.batteryMode,
    required this.riskFlags,
    required this.enabledModuleCodes,
  });
}

// ── Catalog of modules (the "battery") ─────────────────────────────────────────
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

// ── Assignment ──────────────────────────────────────────────────────────────────
class AssignmentEntity {
  final String id;
  final String studentId;
  final String testId;
  final String status; // PENDING / IN_PROGRESS / COMPLETED (representative)
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

// ── Pending module (assignment awaiting a session) ─────────────────────────────
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

// ── Session ─────────────────────────────────────────────────────────────────────
class ScreeningSessionEntity {
  final String id;
  final String assignmentId;
  final String moduleId;
  final String sessionStatus; // IN_PROGRESS / COMPLETED
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

// ── Session items (what the student actually answers) ──────────────────────────
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

// ── Responses submission ─────────────────────────────────────────────────────────
class ItemResponseSubmission {
  final String itemId;
  final String rawResponse;
  final int responseTimeMs;
  final String captureModality; // stt / teclado / tactil
  final double? sttConfidence;
  final String? responseAudioUrl;

  const ItemResponseSubmission({
    required this.itemId,
    required this.rawResponse,
    required this.responseTimeMs,
    required this.captureModality,
    this.sttConfidence,
    this.responseAudioUrl,
  });
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

// ── Diagnosis ─────────────────────────────────────────────────────────────────────
class DiagnosisEntity {
  final String id;
  final String studentId;
  final String assignmentId;
  final String subtype;        // clinical enum (internal)
  final String plnSubtype;     // spanish label to display
  final String severity;       // clinical enum (internal)
  final String plnSeverity;    // spanish label to display
  final double riskProbability;
  final String riskLevel;      // LOW / MEDIUM / HIGH
  final List<String> mainErrorCodes;
  final List<String> recommendedRoute;
  final String recommendationReason;
  final String diagnosedAt;
  final String? modelVersion;
  final String? plnSource;

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
  });
}
