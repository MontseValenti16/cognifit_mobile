import '../../../../core/network/api_client.dart';
import '../models/report_model.dart';

abstract class ReportRemoteDataSource {
  Future<ReportModel> requestReport({required String studentId, required String reportType});
  Future<void> generatePdf(String reportId);
  Future<List<int>> downloadPdf(String reportId);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient client;
  const ReportRemoteDataSourceImpl(this.client);

  @override
  Future<ReportModel> requestReport({required String studentId, required String reportType}) async {
    final json = await client.post('/reports', data: {
      'student_id': studentId,
      'report_type': reportType,
    });
    return ReportModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> generatePdf(String reportId) async {
    await client.post('/reports/$reportId/generate');
  }

  @override
  Future<List<int>> downloadPdf(String reportId) =>
      client.download('/reports/$reportId/download');
}
