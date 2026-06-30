import '../../domain/entities/dashboard_entity.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardEntity> getDashboard();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  @override
  Future<DashboardEntity> getDashboard() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: GET /dashboard
    return const DashboardEntity(
      totalStudents: 24,
      atRisk: 3,
      testsToday: 11,
      activeStudents: [
        StudentSummaryEntity(
          id: '1',
          name: 'Ana M.',
          subtitle: 'Test pendiente',
          status: StudentStatus.pending,
        ),
        StudentSummaryEntity(
          id: '2',
          name: 'Carlos V.',
          subtitle: 'Riesgo leve',
          status: StudentStatus.active,
        ),
        StudentSummaryEntity(
          id: '3',
          name: 'Sofía L.',
          subtitle: 'Dificultad alta',
          status: StudentStatus.atRisk,
        ),
      ],
      groupProgress: 0.67,
      studentsActiveToday: 16,
      weeklyDelta: 0.04,
      alertMessage: 'Luis R. lleva 5 sesiones sin mejora.',
    );
  }
}
