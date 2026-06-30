class ReportEntity {
  final String id;
  final String studentId;
  final String reportType;
  final String status;

  const ReportEntity({
    required this.id,
    required this.studentId,
    required this.reportType,
    required this.status,
  });

  bool get isReady => status == 'READY';
}
