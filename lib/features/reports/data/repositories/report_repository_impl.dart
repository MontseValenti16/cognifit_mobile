import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remote;
  const ReportRepositoryImpl(this.remote);

  @override
  Future<ReportEntity> requestReport({required String studentId, required String reportType}) =>
      remote.requestReport(studentId: studentId, reportType: reportType);

  @override
  Future<void> generatePdf(String reportId) => remote.generatePdf(reportId);

  @override
  Future<List<int>> downloadPdf(String reportId) => remote.downloadPdf(reportId);
}
