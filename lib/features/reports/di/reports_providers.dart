import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/core_providers.dart';
import '../data/datasources/report_remote_datasource.dart';
import '../data/repositories/report_repository_impl.dart';
import '../domain/repositories/report_repository.dart';

/// DI de la feature reports. `reportsViewModelProvider` se declara junto a
/// `ReportsNotifier`/`ReportsState` en `presentation/viewmodels/reports_viewmodel.dart`.
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(ReportRemoteDataSourceImpl(ref.watch(apiClientProvider)));
});
