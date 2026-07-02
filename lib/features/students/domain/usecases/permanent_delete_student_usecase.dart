import '../repositories/student_repository.dart';

class PermanentDeleteStudentUseCase {
  final StudentRepository repository;
  const PermanentDeleteStudentUseCase(this.repository);
  Future<void> call(String id) => repository.permanentDeleteStudent(id);
}
