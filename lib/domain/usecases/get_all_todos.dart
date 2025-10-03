import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

/// Caso de uso para obtener todas las tareas
class GetAllTodos implements UseCaseNoParams<List<Todo>> {
  final TodoRepository repository;

  GetAllTodos(this.repository);

  @override
  Future<Either<Failure, List<Todo>>> call() async {
    return await repository.getAllTodos();
  }
}
