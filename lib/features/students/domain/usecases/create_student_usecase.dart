import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';
class CreateStudentUseCase {
  final StudentRepository repository;
  const CreateStudentUseCase(this.repository);
  Future<StudentEntity> call(CreateStudentParams params) => repository.createStudent(params);
}
