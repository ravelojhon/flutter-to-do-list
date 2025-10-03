import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';

/// Implementación del repositorio de tareas
class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;

  TodoRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Todo>>> getAllTodos() async {
    try {
      final todoModels = await localDataSource.getAllTodos();
      final todos = todoModels.map((model) => model.toEntity()).toList();
      return Right(todos);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Todo?>> getTodoById(String id) async {
    try {
      final todoModel = await localDataSource.getTodoById(id);
      final todo = todoModel?.toEntity();
      return Right(todo);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Todo>>> getTodosByStatus(bool isCompleted) async {
    try {
      final todoModels = await localDataSource.getTodosByStatus(isCompleted);
      final todos = todoModels.map((model) => model.toEntity()).toList();
      return Right(todos);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Todo>>> getTodosByCategory(
    String category,
  ) async {
    try {
      final todoModels = await localDataSource.getTodosByCategory(category);
      final todos = todoModels.map((model) => model.toEntity()).toList();
      return Right(todos);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Todo>>> searchTodos(String query) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      final todoModels = await localDataSource.searchTodos(query);
      final todos = todoModels.map((model) => model.toEntity()).toList();
      return Right(todos);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Todo>> createTodo(Todo todo) async {
    try {
      final todoModel = TodoModel.fromEntity(todo);
      final createdModel = await localDataSource.createTodo(todoModel);
      return Right(createdModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Todo>> updateTodo(Todo todo) async {
    try {
      final todoModel = TodoModel.fromEntity(todo);
      final updatedModel = await localDataSource.updateTodo(todoModel);
      return Right(updatedModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTodo(String id) async {
    try {
      await localDataSource.deleteTodo(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Todo>> completeTodo(String id) async {
    try {
      final updatedModel = await localDataSource.completeTodo(id);
      return Right(updatedModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Todo>> uncompleteTodo(String id) async {
    try {
      final updatedModel = await localDataSource.uncompleteTodo(id);
      return Right(updatedModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteCompletedTodos() async {
    try {
      final deletedCount = await localDataSource.deleteCompletedTodos();
      return Right(deletedCount);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, TodoStats>> getTodoStats() async {
    try {
      final stats = await localDataSource.getTodoStats();
      final domainStats = TodoStats(
        total: stats.total,
        completed: stats.completed,
        pending: stats.pending,
        overdue: stats.overdue,
      );
      return Right(domainStats);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }
}
