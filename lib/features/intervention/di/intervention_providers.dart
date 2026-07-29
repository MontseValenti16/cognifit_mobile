import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/core_providers.dart';
import '../data/datasources/intervention_remote_datasource.dart';
import '../data/repositories/intervention_repository_impl.dart';
import '../domain/repositories/intervention_repository.dart';

final interventionRepositoryProvider = Provider<InterventionRepository>((ref) {
  return InterventionRepositoryImpl(InterventionRemoteDataSourceImpl(ref.watch(apiClientProvider)));
});
