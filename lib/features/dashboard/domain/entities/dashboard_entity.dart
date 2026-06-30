enum StudentStatus { pending, active, atRisk }

class StudentSummaryEntity {
  final String id;
  final String name;
  final String subtitle;
  final StudentStatus status;
  const StudentSummaryEntity({required this.id, required this.name, required this.subtitle, required this.status});
}

class DashboardEntity {
  final int totalStudents;
  final int atRisk;
  final int testsToday;
  final List<StudentSummaryEntity> activeStudents;
  final double groupProgress;
  final int studentsActiveToday;
  final double weeklyDelta;
  final String? alertMessage;
  const DashboardEntity({required this.totalStudents, required this.atRisk, required this.testsToday, required this.activeStudents, required this.groupProgress, required this.studentsActiveToday, required this.weeklyDelta, this.alertMessage});
}
