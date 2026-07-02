import '../entities/admin_user_entity.dart';
import '../repositories/admin_repository.dart';

class CreateUserUseCase {
  final AdminRepository repository;
  const CreateUserUseCase(this.repository);
  Future<AdminUserEntity> call(CreateUserParams params) => repository.createUser(params);
}
