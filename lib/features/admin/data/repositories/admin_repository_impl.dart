import '../../domain/entities/admin_user_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remote;
  const AdminRepositoryImpl(this.remote);

  @override
  Future<List<AdminUserEntity>> getUsers({bool includeInactive = false}) =>
      remote.getUsers(includeInactive: includeInactive);

  @override
  Future<AdminUserEntity> createUser(CreateUserParams params) => remote.createUser(params);

  @override
  Future<AdminUserEntity> updateUser(UpdateUserParams params) => remote.updateUser(params);

  @override
  Future<AdminUserEntity> deactivateUser(String userId) => remote.deactivateUser(userId);

  @override
  Future<List<Map<String, dynamic>>> getStudentsForPicker() => remote.getStudentsForPicker();

  @override
  Future<void> linkParentToStudent(String userId, String studentId) =>
      remote.linkParentToStudent(userId, studentId);
}
