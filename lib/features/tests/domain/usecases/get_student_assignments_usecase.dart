import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';

class GetStudentAssignmentsUseCase {
  final ScreeningRepository repository;
  const GetStudentAssignmentsUseCase(this.repository);
  Future<List<PendingModuleEntity>> call(String studentId) =>
      repository.getStudentAssignments(studentId);
}
