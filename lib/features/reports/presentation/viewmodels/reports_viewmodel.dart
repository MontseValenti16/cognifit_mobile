import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/usecases/download_report_usecase.dart';
import '../../domain/usecases/generate_report_usecase.dart';
import '../../domain/usecases/request_report_usecase.dart';

enum ReportStatus { idle, requesting, generating, downloading, ready, error }

class ReportsViewModel extends ChangeNotifier {
  final RequestReportUseCase _requestReport;
  final GenerateReportUseCase _generateReport;
  final DownloadReportUseCase _downloadReport;

  ReportsViewModel({
    required RequestReportUseCase requestReport,
    required GenerateReportUseCase generateReport,
    required DownloadReportUseCase downloadReport,
  })  : _requestReport = requestReport,
        _generateReport = generateReport,
        _downloadReport = downloadReport;

  ReportStatus _status = ReportStatus.idle;
  String? _error;
  String? _savedPath;
  String _reportType = 'PARENT_SUMMARY';

  ReportStatus get status => _status;
  String? get error => _error;
  String get reportType => _reportType;
  bool get isIdle => _status == ReportStatus.idle;
  bool get isReady => _status == ReportStatus.ready;
  bool get isBusy => _status == ReportStatus.requesting ||
      _status == ReportStatus.generating ||
      _status == ReportStatus.downloading;

  void setReportType(String type) {
    if (isBusy) return;
    _reportType = type;
    notifyListeners();
  }

  Future<void> generate(String studentId) async {
    if (isBusy) return;
    _error = null;
    _savedPath = null;

    _status = ReportStatus.requesting;
    notifyListeners();
    try {
      final report = await _requestReport(studentId: studentId, reportType: _reportType);

      _status = ReportStatus.generating;
      notifyListeners();
      await _generateReport(report.id);

      _status = ReportStatus.downloading;
      notifyListeners();
      final bytes = await _downloadReport(report.id);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/reporte_${report.id}.pdf');
      await file.writeAsBytes(bytes);
      _savedPath = file.path;

      _status = ReportStatus.ready;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _status = ReportStatus.error;
    } catch (_) {
      _error = 'No se pudo generar el reporte.';
      _status = ReportStatus.error;
    }
    notifyListeners();
  }

  Future<void> share() async {
    if (_savedPath == null) return;
    await Share.shareXFiles([XFile(_savedPath!)], text: 'Reporte CogniFit');
  }

  void reset() {
    _status = ReportStatus.idle;
    _error = null;
    _savedPath = null;
    _reportType = 'PARENT_SUMMARY';
    notifyListeners();
  }
}
