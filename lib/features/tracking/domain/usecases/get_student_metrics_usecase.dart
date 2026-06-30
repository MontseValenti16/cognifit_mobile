import '../entities/tracking_entity.dart';
import '../repositories/tracking_repository.dart';
class GetStudentMetricsUseCase {
  final TrackingRepository repository;
  const GetStudentMetricsUseCase(this.repository);
  Future<StudentMetricsEntity> call(String studentId) => repository.getStudentMetrics(studentId);
}
