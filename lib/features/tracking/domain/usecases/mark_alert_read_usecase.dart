import '../entities/tracking_entity.dart';
import '../repositories/tracking_repository.dart';
class MarkAlertReadUseCase {
  final TrackingRepository repository;
  const MarkAlertReadUseCase(this.repository);
  Future<AlertEntity> call(String alertId) => repository.markAlertRead(alertId);
}
