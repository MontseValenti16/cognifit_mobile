import '../entities/screening_entity.dart';
import '../repositories/screening_repository.dart';
class SubmitTeacherResultsUseCase {
  final ScreeningRepository repository;
  const SubmitTeacherResultsUseCase(this.repository);
  Future<TeacherResultEntity> call(String studentId, List<TeacherAnswer> answers) =>
      repository.submitTeacherResults(studentId, answers);
}
