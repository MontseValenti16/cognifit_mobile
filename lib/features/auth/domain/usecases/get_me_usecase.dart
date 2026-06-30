import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
class GetMeUseCase {
  final AuthRepository repository;
  const GetMeUseCase(this.repository);
  Future<UserEntity> call() => repository.getMe();
}
