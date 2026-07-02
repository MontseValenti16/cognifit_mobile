import '../entities/admin_user_entity.dart';
import '../repositories/admin_repository.dart';

class GetUsersUseCase {
  final AdminRepository repository;
  const GetUsersUseCase(this.repository);
  Future<List<AdminUserEntity>> call({bool includeInactive = false}) =>
      repository.getUsers(includeInactive: includeInactive);
}
