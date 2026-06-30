import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Maps directly to AUTH section of API_UI_GUIA.md / API_UI_EJEMPLOS.md
abstract class AuthRemoteDataSource {
  Future<SessionModel> login(String email, String password, {String? deviceInfo});
  Future<UserModel> getMe();
  Future<void> logout(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;
  const AuthRemoteDataSourceImpl(this.client);

  @override
  Future<SessionModel> login(String email, String password, {String? deviceInfo}) async {
    final json = await client.post('/auth/login', data: {
      'email': email,
      'password': password,
      if (deviceInfo != null) 'device_info': deviceInfo,
    });
    return SessionModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getMe() async {
    final json = await client.get('/auth/me');
    return UserModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await client.post('/auth/logout', data: {'refresh_token': refreshToken});
  }
}
