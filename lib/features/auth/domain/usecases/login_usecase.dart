import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<SessionEntity> call(String email, String password, {String? deviceInfo}) =>
      repository.login(email, password, deviceInfo: deviceInfo);
}
