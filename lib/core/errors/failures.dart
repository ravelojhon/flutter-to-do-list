import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Clase base para todos los errores de la aplicación
@freezed
class Failure with _$Failure {
  const factory Failure.serverFailure({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  const factory Failure.cacheFailure({required String message}) = CacheFailure;

  const factory Failure.networkFailure({required String message}) =
      NetworkFailure;

  const factory Failure.validationFailure({
    required String message,
    Map<String, String>? fieldErrors,
  }) = ValidationFailure;

  const factory Failure.unknownFailure({required String message}) =
      UnknownFailure;
}

/// Extensiones para facilitar el manejo de errores
extension FailureExtension on Failure {
  String get userMessage {
    return when(
      serverFailure: (message, statusCode) => 'Error del servidor: $message',
      cacheFailure: (message) => 'Error de caché: $message',
      networkFailure: (message) => 'Error de conexión: $message',
      validationFailure: (message, fieldErrors) =>
          'Error de validación: $message',
      unknownFailure: (message) => 'Error desconocido: $message',
    );
  }

  bool get isServerError => this is ServerFailure;
  bool get isCacheError => this is CacheFailure;
  bool get isNetworkError => this is NetworkFailure;
  bool get isValidationError => this is ValidationFailure;
  bool get isUnknownError => this is UnknownFailure;
}
