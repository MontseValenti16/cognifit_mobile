class SessionRecord {
  final String dayLabel;
  final String time;
  final int score;
  final int delta;
  final bool isRisk;
  const SessionRecord({required this.dayLabel, required this.time, required this.score, required this.delta, required this.isRisk});
}

class StudentProfile {
  final String id;
  final String fullName;
  final String diagnosisConfirmed;
  final String dyslexiaSubtype;
  final String severity;
  final String cieCode;
  final double riskPercentage;
  final int evaluationsCount;
  final String lastSessionTime;
  final String validatedBy;
  final List<SessionRecord> recentSessions;
  const StudentProfile({required this.id, required this.fullName, required this.diagnosisConfirmed, required this.dyslexiaSubtype, required this.severity, required this.cieCode, required this.riskPercentage, required this.evaluationsCount, required this.lastSessionTime, required this.validatedBy, required this.recentSessions});
}
