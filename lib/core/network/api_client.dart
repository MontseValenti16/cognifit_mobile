import 'package:dio/dio.dart';
import '../errors/api_exception.dart';
import '../storage/token_storage.dart';
import 'api_config.dart';

/// Thin wrapper around Dio. Handles:
/// - Authorization header injection
/// - Automatic token refresh on 401 (per API_UI_GUIA section 0)
/// - Normalizing errors into [ApiException]
///
/// Manual DI: one instance lives in ServiceLocator and is shared
/// by every feature's *RemoteDataSourceImpl.
class ApiClient {
  late final Dio _dio;
  final TokenStorage tokenStorage;

  /// Prevents concurrent refresh calls when multiple requests 401 at once.
  Future<void>? _refreshing;

  ApiClient(this.tokenStorage) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.accessToken;
        if (token != null && !options.path.contains('/auth/login') && !options.path.contains('/auth/refresh')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !error.requestOptions.path.contains('/auth/refresh')) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            // Retry the original request with the new token
            final opts = error.requestOptions;
            final token = await tokenStorage.accessToken;
            opts.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            } catch (_) {
              // fallthrough to error
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<bool> _tryRefresh() async {
    _refreshing ??= _doRefresh();
    await _refreshing;
    _refreshing = null;
    return (await tokenStorage.accessToken) != null;
  }

  Future<void> _doRefresh() async {
    try {
      final refreshToken = await tokenStorage.refreshToken;
      if (refreshToken == null) return;
      final response = await _dio.post('/auth/refresh', data: {'refresh_token': refreshToken});
      final newAccess = response.data['access_token'] as String;
      final newRefresh = response.data['refresh_token'] as String;
      await tokenStorage.saveTokens(newAccess, newRefresh);
    } catch (_) {
      await tokenStorage.clear(); // refresh failed too → force re-login
    }
  }

  // ── HTTP verbs — all return parsed JSON or throw ApiException ──────────────

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _wrap(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {dynamic data}) =>
      _wrap(() => _dio.post(path, data: data));

  Future<dynamic> patch(String path, {dynamic data}) =>
      _wrap(() => _dio.patch(path, data: data));

  Future<dynamic> delete(String path) =>
      _wrap(() => _dio.delete(path));

  /// Downloads raw bytes (e.g. PDF reports) instead of parsing JSON.
  Future<List<int>> download(String path) async {
    try {
      final token = await tokenStorage.accessToken;
      final response = await _dio.get<List<int>>(
        path,
        options: Options(
          responseType: ResponseType.bytes,
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      return response.data ?? [];
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> _wrap(Future<Response> Function() call) async {
    try {
      final response = await call();
      return response.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final code = e.response?.statusCode;
    String? backendMessage;
    String? field;
    final data = e.response?.data;
    if (data is Map) {
      backendMessage = data['detail']?.toString() ?? data['message']?.toString();
      if (data['field'] != null) field = data['field'].toString();
    }
    return ApiException.fromStatus(code, backendMessage: backendMessage, field: field);
  }
}
