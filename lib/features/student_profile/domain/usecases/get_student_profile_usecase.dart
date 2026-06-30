import '../entities/student_entity.dart';
import '../repositories/student_profile_repository.dart';
class GetStudentProfileUseCase {
  final StudentProfileRepository repository;
  const GetStudentProfileUseCase(this.repository);
  Future<StudentProfileEntity> call(String id) => repository.getProfile(id);
}
