import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/todo.dart';

/// Repositorio de tareas
abstract class TodoRepository {
  /// Obtiene todas las tareas
  Future<Either<Failure, List<Todo>>> getAllTodos();

  /// Obtiene una tarea por ID
  Future<Either<Failure, Todo?>> getTodoById(String id);

  /// Obtiene tareas por estado
  Future<Either<Failure, List<Todo>>> getTodosByStatus(bool isCompleted);

  /// Obtiene tareas por categoría
  Future<Either<Failure, List<Todo>>> getTodosByCategory(String category);

  /// Busca tareas por texto
  Future<Either<Failure, List<Todo>>> searchTodos(String query);

  /// Crea una nueva tarea
  Future<Either<Failure, Todo>> createTodo(Todo todo);

  /// Actualiza una tarea existente
  Future<Either<Failure, Todo>> updateTodo(Todo todo);

  /// Elimina una tarea
  Future<Either<Failure, void>> deleteTodo(String id);

  /// Marca una tarea como completada
  Future<Either<Failure, Todo>> completeTodo(String id);

  /// Marca una tarea como pendiente
  Future<Either<Failure, Todo>> uncompleteTodo(String id);

  /// Elimina todas las tareas completadas
  Future<Either<Failure, int>> deleteCompletedTodos();

  /// Obtiene estadísticas de tareas
  Future<Either<Failure, TodoStats>> getTodoStats();
}

/// Estadísticas de tareas
class TodoStats {
  final int total;
  final int completed;
  final int pending;
  final int overdue;

  const TodoStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
  });

  double get completionPercentage {
    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }
}
