import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_datasource.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remote;
  const StudentRepositoryImpl(this.remote);

  @override
  Future<List<StudentEntity>> getStudents() => remote.getStudents();
  @override
  Future<StudentEntity> getStudentById(String id) => remote.getStudentById(id);
  @override
  Future<StudentEntity> createStudent(CreateStudentParams params) => remote.createStudent(params);
  @override
  Future<StudentEntity> updateStudent(UpdateStudentParams params) => remote.updateStudent(params);
  @override
  Future<void> deleteStudent(String id) => remote.deleteStudent(id);
  @override
  Future<StudentEntity> activateStudent(String id) => remote.activateStudent(id);
}
