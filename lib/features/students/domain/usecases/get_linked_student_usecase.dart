import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

class GetLinkedStudentUseCase {
  final StudentRepository repository;
  const GetLinkedStudentUseCase(this.repository);
  Future<LinkedStudentResult?> call() => repository.getLinkedStudent();
}
