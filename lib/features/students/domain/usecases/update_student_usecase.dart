import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';
class UpdateStudentUseCase {
  final StudentRepository repository;
  const UpdateStudentUseCase(this.repository);
  Future<StudentEntity> call(UpdateStudentParams params) => repository.updateStudent(params);
}
