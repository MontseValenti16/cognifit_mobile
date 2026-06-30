import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remote;
  const DashboardRepositoryImpl(this.remote);
  @override
  Future<DashboardEntity> getDashboard() => remote.getDashboard();
}
