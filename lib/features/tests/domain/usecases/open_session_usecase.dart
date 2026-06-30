import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';
class OpenSessionUseCase {
  final ScreeningRepository repository;
  const OpenSessionUseCase(this.repository);
  Future<ScreeningSessionEntity> call({required String assignmentId, required String moduleCode, String? deviceId, String? appVersion}) =>
      repository.openSession(assignmentId: assignmentId, moduleCode: moduleCode, deviceId: deviceId, appVersion: appVersion);
}
