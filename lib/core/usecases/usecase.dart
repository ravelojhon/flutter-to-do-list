import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Interfaz base para casos de uso
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Interfaz para casos de uso sin parámetros
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// Clase para casos de uso sin parámetros
class NoParams {
  const NoParams();
}

/// Clase para casos de uso con parámetros opcionales
class OptionalParams {
  final Map<String, dynamic>? data;

  const OptionalParams({this.data});
}
