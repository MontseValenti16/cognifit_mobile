import '../../../../core/network/api_client.dart';
import '../../domain/entities/student_entity.dart';
import '../models/student_model.dart';

abstract class StudentRemoteDataSource {
  Future<List<StudentModel>> getStudents();
  Future<StudentModel> getStudentById(String id);
  Future<StudentModel> createStudent(CreateStudentParams params);
  Future<StudentModel> updateStudent(UpdateStudentParams params);
  Future<void> deleteStudent(String id);
}

/// Maps to ESTUDIANTES section of API_UI_GUIA.md
class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final ApiClient client;
  const StudentRemoteDataSourceImpl(this.client);

  @override
  Future<List<StudentModel>> getStudents() async {
    final json = await client.get('/students');
    return (json as List).map((e) => StudentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<StudentModel> getStudentById(String id) async {
    final json = await client.get('/students/$id');
    return StudentModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<StudentModel> createStudent(CreateStudentParams params) async {
    final json = await client.post('/students', data: StudentModel.createToJson(params));
    return StudentModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<StudentModel> updateStudent(UpdateStudentParams params) async {
    final json = await client.patch('/students/${params.studentId}', data: StudentModel.updateToJson(params));
    return StudentModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> deleteStudent(String id) async {
    await client.delete('/students/$id');
  }
}
