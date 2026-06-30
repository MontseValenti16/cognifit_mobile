/// Central place for backend connection settings.
/// Change [baseUrl] when your Railway/production URL is ready.
class ApiConfig {
  static const String baseUrl = 'https://api-production-f37fe.up.railway.app/api/v1';

  // Connection timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Storage keys (SharedPreferences)
  static const String keyAccessToken = 'cognifit_access_token';
  static const String keyRefreshToken = 'cognifit_refresh_token';
  static const String keyUserId = 'cognifit_user_id';
  static const String keyUserEmail = 'cognifit_user_email';
  static const String keyUserRole = 'cognifit_user_role';
}
