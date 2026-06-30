import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<SessionEntity> login(String email, String password, {String? deviceInfo});
  Future<UserEntity> register(String name, String email, String password);
  Future<UserEntity> getMe();
  Future<void> logout();
}
