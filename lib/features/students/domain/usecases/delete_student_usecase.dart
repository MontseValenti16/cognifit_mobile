import '../repositories/student_repository.dart';
class DeleteStudentUseCase {
  final StudentRepository repository;
  const DeleteStudentUseCase(this.repository);
  Future<void> call(String id) => repository.deleteStudent(id);
}
