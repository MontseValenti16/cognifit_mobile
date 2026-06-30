import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_config.dart';

/// Wraps SharedPreferences for auth/session persistence.
/// Manual DI — instantiate once via ServiceLocator and reuse everywhere.
class TokenStorage {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? email,
    String? role,
  }) async {
    final p = await _instance;
    await p.setString(ApiConfig.keyAccessToken, accessToken);
    await p.setString(ApiConfig.keyRefreshToken, refreshToken);
    if (userId != null) await p.setString(ApiConfig.keyUserId, userId);
    if (email != null) await p.setString(ApiConfig.keyUserEmail, email);
    if (role != null) await p.setString(ApiConfig.keyUserRole, role);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final p = await _instance;
    await p.setString(ApiConfig.keyAccessToken, accessToken);
    await p.setString(ApiConfig.keyRefreshToken, refreshToken);
  }

  Future<String?> get accessToken async => (await _instance).getString(ApiConfig.keyAccessToken);
  Future<String?> get refreshToken async => (await _instance).getString(ApiConfig.keyRefreshToken);
  Future<String?> get userEmail async => (await _instance).getString(ApiConfig.keyUserEmail);
  Future<String?> get userRole async => (await _instance).getString(ApiConfig.keyUserRole);
  Future<String?> get userId async => (await _instance).getString(ApiConfig.keyUserId);

  Future<bool> get hasSession async => (await accessToken) != null;

  Future<void> clear() async {
    final p = await _instance;
    await p.remove(ApiConfig.keyAccessToken);
    await p.remove(ApiConfig.keyRefreshToken);
    await p.remove(ApiConfig.keyUserId);
    await p.remove(ApiConfig.keyUserEmail);
    await p.remove(ApiConfig.keyUserRole);
  }
}
