import '../entities/student_entity.dart';

abstract class StudentRepository {
  Future<List<StudentEntity>> getStudents();
  Future<StudentEntity> getStudentById(String id);
  Future<StudentEntity> createStudent(CreateStudentParams params);

  Future<StudentEntity> updateStudent(UpdateStudentParams params);
  Future<void> deleteStudent(String id);
  Future<void> permanentDeleteStudent(String id);
  Future<StudentEntity> activateStudent(String id);
  Future<LinkedStudentResult?> getLinkedStudent();
}
