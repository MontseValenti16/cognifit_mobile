import '../entities/tracking_entity.dart';
import '../repositories/tracking_repository.dart';
class GetLearningCurveUseCase {
  final TrackingRepository repository;
  const GetLearningCurveUseCase(this.repository);
  Future<LearningCurveEntity> call(String studentId) => repository.getLearningCurve(studentId);
}
