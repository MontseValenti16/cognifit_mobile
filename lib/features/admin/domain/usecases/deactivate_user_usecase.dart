import '../entities/admin_user_entity.dart';
import '../repositories/admin_repository.dart';

class DeactivateUserUseCase {
  final AdminRepository repository;
  const DeactivateUserUseCase(this.repository);
  Future<AdminUserEntity> call(String userId) => repository.deactivateUser(userId);
}
