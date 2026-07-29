import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/core_providers.dart';
import '../data/datasources/screening_remote_datasource.dart';
import '../data/repositories/screening_repository_impl.dart';
import '../domain/repositories/screening_repository.dart';

/// DI de la feature tests (tamizaje). `screeningRepositoryProvider` es
/// público a propósito: lo consumen exercise, specialist, student_profile y
/// dashboard (todas hablan con el mismo endpoint /screening).
/// `testsViewModelProvider` y `calendarioViewModelProvider` se declaran junto
/// a sus respectivos Notifier/State en `presentation/viewmodels/`.
final screeningRepositoryProvider = Provider<ScreeningRepository>((ref) {
  return ScreeningRepositoryImpl(ScreeningRemoteDataSourceImpl(ref.watch(apiClientProvider)));
});
