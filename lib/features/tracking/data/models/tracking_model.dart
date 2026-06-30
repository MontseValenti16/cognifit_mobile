import '../../domain/entities/tracking_entity.dart';

class DiagnosticSessionModel extends DiagnosticSessionEntity {
  const DiagnosticSessionModel({
    required super.sessionNumber, required super.sessionDate, required super.accuracy,
    required super.errorRate, required super.avgResponseMs, required super.riskProbability,
    required super.riskLevel, required super.subtype, required super.severity,
  });

  factory DiagnosticSessionModel.fromJson(Map<String, dynamic> j) => DiagnosticSessionModel(
    sessionNumber: j['session_number'] as int? ?? 0,
    sessionDate: j['session_date'] as String? ?? '',
    accuracy: (j['accuracy'] as num?)?.toDouble() ?? 0,
    errorRate: (j['error_rate'] as num?)?.toDouble() ?? 0,
    avgResponseMs: j['avg_response_ms'] as int? ?? 0,
    riskProbability: (j['risk_probability'] as num?)?.toDouble() ?? 0,
    riskLevel: j['risk_level'] as String? ?? 'LOW',
    subtype: j['subtype'] as String? ?? '',
    severity: j['severity'] as String? ?? '',
  );
}

class ExerciseSessionModel extends ExerciseSessionEntity {
  const ExerciseSessionModel({
    required super.startedAt, super.completedAt, required super.score,
    required super.accuracyPct, required super.avgResponseMs,
    required super.exerciseCode, required super.title,
  });

  factory ExerciseSessionModel.fromJson(Map<String, dynamic> j) => ExerciseSessionModel(
    startedAt: j['started_at'] as String? ?? '',
    completedAt: j['completed_at'] as String?,
    score: j['score'] as int? ?? 0,
    accuracyPct: (j['accuracy_pct'] as num?)?.toDouble() ?? 0,
    avgResponseMs: j['avg_response_ms'] as int? ?? 0,
    exerciseCode: j['exercise_code'] as String? ?? '',
    title: j['title'] as String? ?? '',
  );
}

class LearningCurveModel extends LearningCurveEntity {
  const LearningCurveModel({
    required super.studentId, required super.diagnosticSessions, required super.exerciseSessions,
  });

  factory LearningCurveModel.fromJson(Map<String, dynamic> j) => LearningCurveModel(
    studentId: j['student_id'] as String? ?? '',
    diagnosticSessions: (j['diagnostic_sessions'] as List? ?? []).map((e) => DiagnosticSessionModel.fromJson(e)).toList(),
    exerciseSessions: (j['exercise_sessions'] as List? ?? []).map((e) => ExerciseSessionModel.fromJson(e)).toList(),
  );
}

class StudentMetricsModel extends StudentMetricsEntity {
  const StudentMetricsModel({
    required super.diagnosticSessions, required super.exerciseSessions,
    required super.latestRiskLevel, required super.latestSubtype, required super.latestSeverity,
    required super.recentAvgAccuracy, required super.firstAccuracy, required super.lastAccuracy,
    required super.trend,
  });

  factory StudentMetricsModel.fromJson(Map<String, dynamic> j) => StudentMetricsModel(
    diagnosticSessions: j['diagnostic_sessions'] as int? ?? 0,
    exerciseSessions: j['exercise_sessions'] as int? ?? 0,
    latestRiskLevel: j['latest_risk_level'] as String? ?? 'LOW',
    latestSubtype: j['latest_subtype'] as String? ?? '',
    latestSeverity: j['latest_severity'] as String? ?? '',
    recentAvgAccuracy: (j['recent_avg_accuracy'] as num?)?.toDouble() ?? 0,
    firstAccuracy: (j['first_accuracy'] as num?)?.toDouble() ?? 0,
    lastAccuracy: (j['last_accuracy'] as num?)?.toDouble() ?? 0,
    trend: j['trend'] as String? ?? 'n/a',
  );
}

class GroupMetricsModel extends GroupMetricsEntity {
  const GroupMetricsModel({
    required super.groupId, required super.totalStudents,
    required super.highRisk, required super.mediumRisk, required super.lowRisk,
  });

  factory GroupMetricsModel.fromJson(Map<String, dynamic> j) => GroupMetricsModel(
    groupId: j['group_id'] as String? ?? '',
    totalStudents: j['total_students'] as int? ?? 0,
    highRisk: j['high_risk'] as int? ?? 0,
    mediumRisk: j['medium_risk'] as int? ?? 0,
    lowRisk: j['low_risk'] as int? ?? 0,
  );
}

class AlertModel extends AlertEntity {
  const AlertModel({
    required super.id, required super.studentId, required super.alertType,
    required super.message, required super.suggestedAction, required super.urgency,
    required super.isRead, required super.createdAt, super.readAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> j) => AlertModel(
    id: j['id'] as String,
    studentId: j['student_id'] as String? ?? '',
    alertType: j['alert_type'] as String? ?? '',
    message: j['message'] as String? ?? '',
    suggestedAction: j['suggested_action'] as String? ?? '',
    urgency: j['urgency'] as String? ?? 'LOW',
    isRead: j['is_read'] as bool? ?? false,
    createdAt: j['created_at'] as String? ?? '',
    readAt: j['read_at'] as String?,
  );
}
