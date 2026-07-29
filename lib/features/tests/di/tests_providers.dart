import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/core_providers.dart';
import '../data/datasources/screening_remote_datasource.dart';
import '../data/repositories/screening_repository_impl.dart';
import '../domain/repositories/screening_repository.dart';

final screeningRepositoryProvider = Provider<ScreeningRepository>((ref) {
  return ScreeningRepositoryImpl(ScreeningRemoteDataSourceImpl(ref.watch(apiClientProvider)));
});
