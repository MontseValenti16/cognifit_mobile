import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';
class GetStudentByIdUseCase {
  final StudentRepository repository;
  const GetStudentByIdUseCase(this.repository);
  Future<StudentEntity> call(String id) => repository.getStudentById(id);
}
