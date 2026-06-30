import '../entities/student_entity.dart';
abstract class StudentProfileRepository {
  Future<StudentProfileEntity> getProfile(String studentId);
}
