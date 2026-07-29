import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/errors/api_exception.dart';
import '../../di/reports_providers.dart';
import '../../domain/usecases/download_report_usecase.dart';
import '../../domain/usecases/generate_report_usecase.dart';
import '../../domain/usecases/request_report_usecase.dart';

enum ReportStage { requesting, generating, downloading }

const _unset = Object();

/// `result` es data(null) en idle, data(path) cuando el PDF ya se guardó, y
/// AsyncLoading/AsyncError durante la generación. `stage` distingue en cuál
/// de las tres llamadas al backend va mientras `result` está en loading —
/// AsyncValue por sí solo no alcanza para el label de progreso de la UI.
class ReportsState {
  final AsyncValue<String?> result;
  final ReportStage? stage;
  final String reportType;

  const ReportsState({
    this.result = const AsyncValue.data(null),
    this.stage,
    this.reportType = 'PARENT_SUMMARY',
  });

  bool get isBusy => result.isLoading;
  bool get isIdle => !isBusy && !result.hasError && result.valueOrNull == null;
  bool get isReady => result.valueOrNull != null;
  bool get isError => result.hasError;
  String? get savedPath => result.valueOrNull;

  String? get error {
    final err = result.error;
    if (err == null) return null;
    return err is ApiException ? err.userMessage : 'No se pudo generar el reporte.';
  }

  ReportsState copyWith({AsyncValue<String?>? result, Object? stage = _unset, String? reportType}) {
    return ReportsState(
      result: result ?? this.result,
      stage: identical(stage, _unset) ? this.stage : stage as ReportStage?,
      reportType: reportType ?? this.reportType,
    );
  }
}

class ReportsNotifier extends Notifier<ReportsState> {
  late RequestReportUseCase _requestReport;
  late GenerateReportUseCase _generateReport;
  late DownloadReportUseCase _downloadReport;

  @override
  ReportsState build() {
    final repo = ref.watch(reportRepositoryProvider);
    _requestReport = RequestReportUseCase(repo);
    _generateReport = GenerateReportUseCase(repo);
    _downloadReport = DownloadReportUseCase(repo);
    return const ReportsState();
  }

  void setReportType(String type) {
    if (state.isBusy) return;
    state = state.copyWith(reportType: type);
  }

  Future<void> generate(String studentId) async {
    if (state.isBusy) return;
    state = state.copyWith(result: const AsyncValue.loading(), stage: ReportStage.requesting);
    try {
      final report = await _requestReport(studentId: studentId, reportType: state.reportType);

      state = state.copyWith(stage: ReportStage.generating);
      await _generateReport(report.id);

      state = state.copyWith(stage: ReportStage.downloading);
      final bytes = await _downloadReport(report.id);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/reporte_${report.id}.pdf');
      await file.writeAsBytes(bytes);

      state = state.copyWith(result: AsyncValue.data(file.path), stage: null);
    } catch (e, st) {
      state = state.copyWith(result: AsyncValue.error(e, st), stage: null);
    }
  }

  Future<void> share() async {
    final path = state.savedPath;
    if (path == null) return;
    await Share.shareXFiles([XFile(path)], text: 'Reporte CogniFit');
  }

  void reset() => state = ReportsState(reportType: state.reportType);
}

final reportsViewModelProvider = NotifierProvider<ReportsNotifier, ReportsState>(ReportsNotifier.new);
