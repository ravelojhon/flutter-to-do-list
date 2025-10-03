import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../database/app_database.dart';
import '../database/tasks_dao_enhanced.dart';
import '../models/task_model.dart';

/// Implementación del repositorio de tareas usando Drift
class TaskRepositoryImpl implements TaskRepository {
  final AppDatabase _database;
  late final TasksDaoEnhanced _dao;

  TaskRepositoryImpl(this._database) {
    _dao = TasksDaoEnhanced(_database);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      return await _dao.getAllTasksAsEntities();
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<void> addTask(Task task) async {
    try {
      await _dao.insertTaskEntity(task);
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      if (task.id == null) {
        throw const CacheException(message: 'Task ID is required for update');
      }

      final success = await _dao.updateTaskEntity(task);
      if (!success) {
        throw const CacheException(message: 'Task not found for update');
      }
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    try {
      final success = await _dao.deleteTask(id);
      if (!success) {
        throw const CacheException(message: 'Task not found for deletion');
      }
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<Task?> getTaskById(int id) async {
    try {
      return await _dao.getTaskEntityById(id);
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<List<Task>> getTasksByStatus(bool isCompleted) async {
    try {
      return await _dao.getTasksByStatusAsEntities(isCompleted);
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllTasks();
      }
      return await _dao.searchTasksAsEntities(query);
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<List<Task>> getRecentTasks(int limit) async {
    try {
      if (limit <= 0) {
        throw const CacheException(message: 'Limit must be greater than 0');
      }
      return await _dao.getRecentTasksAsEntities(limit);
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<TaskStats> getTaskStats() async {
    try {
      return await _dao.getTaskStatsFromModels();
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  /// Marcar tarea como completada
  Future<void> markTaskAsCompleted(int id) async {
    try {
      final success = await _dao.markTaskAsCompleted(id);
      if (!success) {
        throw const CacheException(message: 'Task not found');
      }
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  /// Marcar tarea como pendiente
  Future<void> markTaskAsPending(int id) async {
    try {
      final success = await _dao.markTaskAsPending(id);
      if (!success) {
        throw const CacheException(message: 'Task not found');
      }
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  /// Actualizar título de tarea
  Future<void> updateTaskTitle(int id, String newTitle) async {
    try {
      if (newTitle.trim().isEmpty) {
        throw const CacheException(message: 'Task title cannot be empty');
      }

      final success = await _dao.updateTaskTitle(id, newTitle.trim());
      if (!success) {
        throw const CacheException(message: 'Task not found');
      }
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  /// Obtener tareas por rango de fechas
  Future<List<Task>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (startDate.isAfter(endDate)) {
        throw const CacheException(
          message: 'Start date must be before end date',
        );
      }

      return await _dao.getTasksByDateRangeAsEntities(startDate, endDate);
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  /// Eliminar todas las tareas completadas
  Future<int> deleteCompletedTasks() async {
    try {
      return await _dao.deleteCompletedTasks();
    } on Exception catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  /// Obtener tareas pendientes
  Future<List<Task>> getPendingTasks() async {
    return await getTasksByStatus(false);
  }

  /// Obtener tareas completadas
  Future<List<Task>> getCompletedTasks() async {
    return await getTasksByStatus(true);
  }

  /// Cerrar la conexión a la base de datos
  Future<void> close() async {
    await _database.close();
  }

  /// Mapear excepciones a failures
  Failure _mapExceptionToFailure(Exception e) {
    if (e is CacheException) {
      return CacheFailure(message: e.message);
    } else if (e is ServerException) {
      return ServerFailure(message: e.message);
    } else if (e is NetworkException) {
      return ServerFailure(message: e.message);
    } else {
      return UnexpectedFailure(message: e.toString());
    }
  }
}
