import '../repositories/report_repository.dart';

class GenerateReportUseCase {
  final ReportRepository repository;
  const GenerateReportUseCase(this.repository);
  Future<void> call(String reportId) => repository.generatePdf(reportId);
}
