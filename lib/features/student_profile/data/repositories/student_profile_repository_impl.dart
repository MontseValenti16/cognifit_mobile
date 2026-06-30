import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_profile_repository.dart';
import '../datasources/student_profile_remote_datasource.dart';
class StudentProfileRepositoryImpl implements StudentProfileRepository {
  final StudentProfileRemoteDataSource remote;
  const StudentProfileRepositoryImpl(this.remote);
  @override
  Future<StudentProfileEntity> getProfile(String id) => remote.getProfile(id);
}
