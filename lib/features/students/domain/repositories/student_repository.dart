import '../entities/student_entity.dart';

abstract class StudentRepository {
  Future<List<StudentEntity>> getStudents();
  Future<StudentEntity> getStudentById(String id);
  Future<StudentEntity> createStudent(CreateStudentParams params);

  /// NOTE: PATCH/DELETE /students/{id} are not explicitly documented in
  /// API_UI_GUIA — only POST/GET are. Implemented here following the same
  /// REST convention used for /admin/users. Verify against the real backend
  /// and adjust the datasource if the route differs.
  Future<StudentEntity> updateStudent(UpdateStudentParams params);
  Future<void> deleteStudent(String id);
  Future<void> permanentDeleteStudent(String id);
  Future<StudentEntity> activateStudent(String id);
  Future<LinkedStudentResult?> getLinkedStudent();
}
