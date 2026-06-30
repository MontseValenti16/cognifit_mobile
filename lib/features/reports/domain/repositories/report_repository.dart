import '../entities/report_entity.dart';

abstract class ReportRepository {
  Future<ReportEntity> requestReport({required String studentId, required String reportType});
  Future<void> generatePdf(String reportId);
  Future<List<int>> downloadPdf(String reportId);
}
