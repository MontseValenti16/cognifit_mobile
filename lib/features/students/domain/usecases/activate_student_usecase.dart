import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

class ActivateStudentUseCase {
  final StudentRepository repository;
  const ActivateStudentUseCase(this.repository);
  Future<StudentEntity> call(String id) => repository.activateStudent(id);
}
