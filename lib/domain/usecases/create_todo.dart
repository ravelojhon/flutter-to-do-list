import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

/// Parámetros para crear una tarea
class CreateTodoParams {
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int? priority;
  final String? category;
  final List<String>? tags;

  const CreateTodoParams({
    required this.title,
    this.description,
    this.dueDate,
    this.priority,
    this.category,
    this.tags,
  });
}

/// Caso de uso para crear una tarea
class CreateTodo implements UseCase<Todo, CreateTodoParams> {
  final TodoRepository repository;

  CreateTodo(this.repository);

  @override
  Future<Either<Failure, Todo>> call(CreateTodoParams params) async {
    // Validaciones de negocio
    if (params.title.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'El título no puede estar vacío'),
      );
    }

    if (params.title.length > 100) {
      return const Left(
        ValidationFailure(
          message: 'El título no puede tener más de 100 caracteres',
        ),
      );
    }

    if (params.description != null && params.description!.length > 500) {
      return const Left(
        ValidationFailure(
          message: 'La descripción no puede tener más de 500 caracteres',
        ),
      );
    }

    // Crear la entidad Todo
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: params.title.trim(),
      description: params.description?.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
      dueDate: params.dueDate,
      priority: params.priority ?? 1,
      category: params.category,
      tags: params.tags,
    );

    return await repository.createTodo(todo);
  }
}
