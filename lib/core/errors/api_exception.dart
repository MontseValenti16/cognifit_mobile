class ApiException implements Exception {
  final int? statusCode;
  final String userMessage;
  final String? fieldError;
  final dynamic raw;

  const ApiException({
    this.statusCode,
    required this.userMessage,
    this.fieldError,
    this.raw,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidation => statusCode == 422;
  bool get isNetwork => statusCode == null;

  @override
  String toString() => userMessage;

  factory ApiException.fromStatus(int? code, {String? backendMessage, String? field}) {
    final msg = switch (code) {
      401 => 'Tu sesión expiró. Inicia sesión de nuevo.',
      403 => backendMessage ?? 'No tienes permisos para esta acción.',
      404 => 'Recurso no encontrado.',
      409 => backendMessage ?? 'Ya existe un registro con estos datos.',
      422 => backendMessage ?? 'Revisa los datos ingresados.',
      null => 'No se pudo conectar con el servidor. Verifica tu conexión.',
      _ => backendMessage ?? 'Ocurrió un error inesperado.',
    };
    return ApiException(statusCode: code, userMessage: msg, fieldError: field);
  }
}
