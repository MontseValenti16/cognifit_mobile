import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final TokenStorage tokenStorage;
  const AuthRepositoryImpl(this.remote, this.tokenStorage);

  @override
  Future<SessionEntity> login(String email, String password, {String? deviceInfo}) async {
    final session = await remote.login(email, password, deviceInfo: deviceInfo);
    await tokenStorage.saveTokens(session.accessToken, session.refreshToken);
    // Fetch profile right after login so we know the role for navigation/permissions.
    final me = await remote.getMe();
    await tokenStorage.saveSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userId: me.id, email: me.email, role: roleToString(me.role),
    );
    return session;
  }

  @override
  Future<UserEntity> register(String name, String email, String password) async {
    // Note: This assumes there's a /auth/register endpoint.
    // Update the datasource if the actual backend endpoint differs.
    // For now, we'll delegate to a NotImplementedError or similar.
    throw UnimplementedError('Register endpoint not yet implemented in datasource');
  }

  @override
  Future<UserEntity> getMe() => remote.getMe();

  @override
  Future<void> logout() async {
    final refreshToken = await tokenStorage.refreshToken;
    if (refreshToken != null) {
      try { await remote.logout(refreshToken); } catch (_) {} // best-effort
    }
    await tokenStorage.clear();
  }
}
