import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';

class GetTeacherAssignmentsUseCase {
  final ScreeningRepository repository;
  const GetTeacherAssignmentsUseCase(this.repository);

  Future<List<TeacherAssignmentEntity>> call({String status = 'PENDING,IN_PROGRESS'}) =>
      repository.getTeacherAssignments(status: status);
}
