import '../entities/admin_user_entity.dart';

abstract class AdminRepository {
  Future<List<AdminUserEntity>> getUsers({bool includeInactive = false});
  Future<AdminUserEntity> createUser(CreateUserParams params);
  Future<AdminUserEntity> updateUser(UpdateUserParams params);
  Future<AdminUserEntity> deactivateUser(String userId);
  Future<List<Map<String, dynamic>>> getStudentsForPicker();
  Future<void> linkParentToStudent(String userId, String studentId);
}
