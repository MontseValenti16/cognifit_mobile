import '../entities/admin_user_entity.dart';
import '../repositories/admin_repository.dart';

class UpdateUserUseCase {
  final AdminRepository repository;
  const UpdateUserUseCase(this.repository);
  Future<AdminUserEntity> call(UpdateUserParams params) => repository.updateUser(params);
}
