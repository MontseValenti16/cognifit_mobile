import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/core_providers.dart';
import '../data/datasources/institution_remote_datasource.dart';
import '../data/repositories/institution_repository_impl.dart';
import '../domain/repositories/institution_repository.dart';

/// DI de la feature institutions. `institutionViewModelProvider` se declara
/// junto a `InstitutionNotifier`/`InstitutionState` en
/// `presentation/viewmodels/institution_viewmodel.dart`.
final institutionRepositoryProvider = Provider<InstitutionRepository>((ref) {
  return InstitutionRepositoryImpl(InstitutionRemoteDataSourceImpl(ref.watch(apiClientProvider)));
});
