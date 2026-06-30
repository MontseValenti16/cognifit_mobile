import '../../domain/entities/report_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.studentId,
    required super.reportType,
    required super.status,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
    id: json['id'] as String,
    studentId: (json['student_id'] ?? '') as String,
    reportType: (json['report_type'] ?? '') as String,
    status: (json['status'] ?? 'PENDING') as String,
  );
}
