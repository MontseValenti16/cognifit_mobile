import '../repositories/report_repository.dart';

class DownloadReportUseCase {
  final ReportRepository repository;
  const DownloadReportUseCase(this.repository);
  Future<List<int>> call(String reportId) => repository.downloadPdf(reportId);
}
