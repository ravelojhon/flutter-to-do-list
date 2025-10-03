import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';

/// Use case para obtener todas las tareas
class GetTasks implements UseCase<List<Task>, NoParams> {
  final TaskRepository _repository;

  GetTasks(this._repository);

  @override
  Future<List<Task>> call(NoParams params) async {
    try {
      return await _repository.getAllTasks();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(message: 'Error al obtener tareas: $e');
    }
  }
}

/// Use case para obtener tareas por estado
class GetTasksByStatus implements UseCase<List<Task>, bool> {
  final TaskRepository _repository;

  GetTasksByStatus(this._repository);

  @override
  Future<List<Task>> call(bool isCompleted) async {
    try {
      return await _repository.getTasksByStatus(isCompleted);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(
        message: 'Error al obtener tareas por estado: $e',
      );
    }
  }
}

/// Use case para obtener tareas pendientes
class GetPendingTasks implements UseCase<List<Task>, NoParams> {
  final TaskRepository _repository;

  GetPendingTasks(this._repository);

  @override
  Future<List<Task>> call(NoParams params) async {
    try {
      return await _repository.getPendingTasks();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(
        message: 'Error al obtener tareas pendientes: $e',
      );
    }
  }
}

/// Use case para obtener tareas completadas
class GetCompletedTasks implements UseCase<List<Task>, NoParams> {
  final TaskRepository _repository;

  GetCompletedTasks(this._repository);

  @override
  Future<List<Task>> call(NoParams params) async {
    try {
      return await _repository.getCompletedTasks();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(
        message: 'Error al obtener tareas completadas: $e',
      );
    }
  }
}

/// Use case para buscar tareas
class SearchTasks implements UseCase<List<Task>, String> {
  final TaskRepository _repository;

  SearchTasks(this._repository);

  @override
  Future<List<Task>> call(String query) async {
    try {
      if (query.trim().isEmpty) {
        throw const CacheFailure(
          message: 'Query de búsqueda no puede estar vacía',
        );
      }
      return await _repository.searchTasks(query);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(message: 'Error al buscar tareas: $e');
    }
  }
}

/// Use case para obtener tareas recientes
class GetRecentTasks implements UseCase<List<Task>, int> {
  final TaskRepository _repository;

  GetRecentTasks(this._repository);

  @override
  Future<List<Task>> call(int limit) async {
    try {
      if (limit <= 0) {
        throw const CacheFailure(message: 'El límite debe ser mayor que 0');
      }
      return await _repository.getRecentTasks(limit);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(message: 'Error al obtener tareas recientes: $e');
    }
  }
}

/// Use case para obtener estadísticas de tareas
class GetTaskStats implements UseCase<TaskStats, NoParams> {
  final TaskRepository _repository;

  GetTaskStats(this._repository);

  @override
  Future<TaskStats> call(NoParams params) async {
    try {
      return await _repository.getTaskStats();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(message: 'Error al obtener estadísticas: $e');
    }
  }
}
