import '../entities/tracking_entity.dart';
import '../repositories/tracking_repository.dart';
class GetAlertsUseCase {
  final TrackingRepository repository;
  const GetAlertsUseCase(this.repository);
  Future<List<AlertEntity>> call({bool onlyUnread = false}) => repository.getAlerts(onlyUnread: onlyUnread);
}
