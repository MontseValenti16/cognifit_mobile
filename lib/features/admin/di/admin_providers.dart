import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/core_providers.dart';
import '../data/datasources/admin_remote_datasource.dart';
import '../data/repositories/admin_repository_impl.dart';
import '../domain/repositories/admin_repository.dart';

/// DI de la feature admin. `adminViewModelProvider` se declara junto a
/// `AdminNotifier`/`AdminState` en `presentation/viewmodels/admin_viewmodel.dart`.
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(AdminRemoteDataSourceImpl(ref.watch(apiClientProvider)));
});
