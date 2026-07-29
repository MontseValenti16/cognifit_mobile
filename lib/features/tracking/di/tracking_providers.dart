import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/core_providers.dart';
import '../data/datasources/tracking_remote_datasource.dart';
import '../data/repositories/tracking_repository_impl.dart';
import '../domain/repositories/tracking_repository.dart';

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepositoryImpl(TrackingRemoteDataSourceImpl(ref.watch(apiClientProvider)));
});
