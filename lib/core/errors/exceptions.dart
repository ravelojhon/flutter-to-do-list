/// Excepciones base para la aplicación
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({required this.message, this.code, this.details});

  @override
  String toString() => 'AppException: $message';
}

/// Excepción del servidor
class ServerException extends AppException {
  const ServerException({required super.message, super.code, super.details});
}

/// Excepción de caché
class CacheException extends AppException {
  const CacheException({required super.message, super.code, super.details});
}

/// Excepción de red
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code, super.details});
}

/// Excepción de validación
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors,
    super.code,
    super.details,
  });
}

/// Excepción desconocida
class UnknownException extends AppException {
  const UnknownException({required super.message, super.code, super.details});
}
