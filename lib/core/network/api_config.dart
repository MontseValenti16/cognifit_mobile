class ApiConfig {
  static const String baseUrl = 'https://api-production-2ba0.up.railway.app/api/v1';

  static const String conektaPublicKey = String.fromEnvironment(
    'CONEKTA_PUBLIC_KEY',
    defaultValue: 'key_dummy_change_me',
  );
  static const String conektaBaseUrl = 'https://api.conekta.io';
  static const String conektaApiVersion = '2.1.0';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const String keyAccessToken = 'cognifit_access_token';
  static const String keyRefreshToken = 'cognifit_refresh_token';
  static const String keyUserId = 'cognifit_user_id';
  static const String keyUserEmail = 'cognifit_user_email';
  static const String keyUserRole = 'cognifit_user_role';
}
