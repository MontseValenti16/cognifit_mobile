import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

class RequestReportUseCase {
  final ReportRepository repository;
  const RequestReportUseCase(this.repository);
  Future<ReportEntity> call({required String studentId, required String reportType}) =>
      repository.requestReport(studentId: studentId, reportType: reportType);
}
