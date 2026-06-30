/// TRACKING — progreso y alertas (API_UI_GUIA section 6)

class DiagnosticSessionEntity {
  final int sessionNumber;
  final String sessionDate;
  final double accuracy;
  final double errorRate;
  final int avgResponseMs;
  final double riskProbability;
  final String riskLevel;
  final String subtype;
  final String severity;

  const DiagnosticSessionEntity({
    required this.sessionNumber, required this.sessionDate, required this.accuracy,
    required this.errorRate, required this.avgResponseMs, required this.riskProbability,
    required this.riskLevel, required this.subtype, required this.severity,
  });
}

class ExerciseSessionEntity {
  final String startedAt;
  final String? completedAt;
  final int score;
  final double accuracyPct;
  final int avgResponseMs;
  final String exerciseCode;
  final String title;

  const ExerciseSessionEntity({
    required this.startedAt, this.completedAt, required this.score,
    required this.accuracyPct, required this.avgResponseMs,
    required this.exerciseCode, required this.title,
  });
}

class LearningCurveEntity {
  final String studentId;
  final List<DiagnosticSessionEntity> diagnosticSessions;
  final List<ExerciseSessionEntity> exerciseSessions;

  const LearningCurveEntity({
    required this.studentId,
    required this.diagnosticSessions,
    required this.exerciseSessions,
  });
}

class StudentMetricsEntity {
  final int diagnosticSessions;
  final int exerciseSessions;
  final String latestRiskLevel;
  final String latestSubtype;
  final String latestSeverity;
  final double recentAvgAccuracy;
  final double firstAccuracy;
  final double lastAccuracy;
  final String trend; // improving / regressing / flat / n/a

  const StudentMetricsEntity({
    required this.diagnosticSessions, required this.exerciseSessions,
    required this.latestRiskLevel, required this.latestSubtype, required this.latestSeverity,
    required this.recentAvgAccuracy, required this.firstAccuracy, required this.lastAccuracy,
    required this.trend,
  });
}

class GroupMetricsEntity {
  final String groupId;
  final int totalStudents;
  final int highRisk;
  final int mediumRisk;
  final int lowRisk;

  const GroupMetricsEntity({
    required this.groupId, required this.totalStudents,
    required this.highRisk, required this.mediumRisk, required this.lowRisk,
  });
}

class AlertEntity {
  final String id;
  final String studentId;
  final String alertType; // STAGNATION / LEVEL_UP
  final String message;
  final String suggestedAction;
  final String urgency; // HIGH / MEDIUM / LOW
  final bool isRead;
  final String createdAt;
  final String? readAt;

  const AlertEntity({
    required this.id, required this.studentId, required this.alertType,
    required this.message, required this.suggestedAction, required this.urgency,
    required this.isRead, required this.createdAt, this.readAt,
  });

  AlertEntity copyWith({bool? isRead, String? readAt}) => AlertEntity(
    id: id, studentId: studentId, alertType: alertType, message: message,
    suggestedAction: suggestedAction, urgency: urgency,
    isRead: isRead ?? this.isRead, createdAt: createdAt, readAt: readAt ?? this.readAt,
  );
}
