import '../../domain/entities/student_entity.dart';
abstract class StudentProfileRemoteDataSource {
  Future<StudentProfileEntity> getProfile(String studentId);
}
class StudentProfileRemoteDataSourceImpl implements StudentProfileRemoteDataSource {
  @override
  Future<StudentProfileEntity> getProfile(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: GET /students/:id/profile
    return const StudentProfileEntity(
      id: 'luis-r', fullName: 'Luis Ramírez',
      diagnosisConfirmed: 'DISLEXIA CONFIRMADA · ID #2024-0138',
      dyslexiaSubtype: 'Fonológica', severity: 'Severa', cieCode: 'CIE-11 · 6A03.0',
      riskPercentage: 0.87, evaluationsCount: 3,
      lastSessionTime: 'Hoy 09:15', validatedBy: 'Pendiente',
      recentSessions: [
        SessionRecordEntity(dayLabel: 'Hoy', time: '09:15', score: 72, delta: 4, isRisk: false),
        SessionRecordEntity(dayLabel: 'Lun', time: '08:40', score: 68, delta: 2, isRisk: false),
        SessionRecordEntity(dayLabel: 'Vie', time: '09:00', score: 66, delta: -1, isRisk: true),
      ],
    );
  }
}
