import '../entities/tracking_entity.dart';
import '../repositories/tracking_repository.dart';
class GetGroupMetricsUseCase {
  final TrackingRepository repository;
  const GetGroupMetricsUseCase(this.repository);
  Future<GroupMetricsEntity> call(String groupId) => repository.getGroupMetrics(groupId);
}
