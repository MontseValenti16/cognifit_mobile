import '../entities/dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';
class GetDashboardUseCase {
  final DashboardRepository repository;
  const GetDashboardUseCase(this.repository);
  Future<DashboardEntity> call() => repository.getDashboard();
}
