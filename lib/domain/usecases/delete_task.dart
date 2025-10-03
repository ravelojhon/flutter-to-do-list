import '../repositories/task_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';

/// Parámetros para eliminar una tarea
class DeleteTaskParams {
  final int id;
  final bool force; // Si debe eliminar sin validaciones adicionales

  const DeleteTaskParams({required this.id, this.force = false});

  @override
  String toString() {
    return 'DeleteTaskParams(id: $id, force: $force)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteTaskParams && other.id == id && other.force == force;
  }

  @override
  int get hashCode {
    return id.hashCode ^ force.hashCode;
  }
}

/// Use case para eliminar una tarea
class DeleteTask implements UseCase<void, DeleteTaskParams> {
  final TaskRepository _repository;

  DeleteTask(this._repository);

  @override
  Future<void> call(DeleteTaskParams params) async {
    try {
      // Validar parámetros
      _validateParams(params);

      // Verificar que la tarea existe (si no es eliminación forzada)
      if (!params.force) {
        final existingTask = await _repository.getTaskById(params.id);
        if (existingTask == null) {
          throw const CacheFailure(message: 'Tarea no encontrada');
        }
      }

      // Eliminar a través del repositorio
      await _repository.deleteTask(params.id);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(message: 'Error al eliminar tarea: $e');
    }
  }

  /// Validar parámetros de entrada
  void _validateParams(DeleteTaskParams params) {
    if (params.id <= 0) {
      throw const CacheFailure(message: 'El ID de la tarea debe ser válido');
    }
  }
}

/// Use case para eliminar tarea por ID simple
class DeleteTaskById implements UseCase<void, int> {
  final TaskRepository _repository;

  DeleteTaskById(this._repository);

  @override
  Future<void> call(int taskId) async {
    try {
      if (taskId <= 0) {
        throw const CacheFailure(message: 'El ID de la tarea debe ser válido');
      }

      // Verificar que la tarea existe
      final existingTask = await _repository.getTaskById(taskId);
      if (existingTask == null) {
        throw const CacheFailure(message: 'Tarea no encontrada');
      }

      // Eliminar a través del repositorio
      await _repository.deleteTask(taskId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(message: 'Error al eliminar tarea por ID: $e');
    }
  }
}

/// Use case para eliminar múltiples tareas
class DeleteMultipleTasks implements UseCase<void, List<int>> {
  final TaskRepository _repository;

  DeleteMultipleTasks(this._repository);

  @override
  Future<void> call(List<int> taskIds) async {
    try {
      if (taskIds.isEmpty) {
        throw const CacheFailure(
          message: 'No se pueden eliminar tareas vacías',
        );
      }

      if (taskIds.length > 50) {
        throw const CacheFailure(
          message: 'No se pueden eliminar más de 50 tareas a la vez',
        );
      }

      // Validar cada ID
      for (final taskId in taskIds) {
        if (taskId <= 0) {
          throw const CacheFailure(
            message: 'El ID de la tarea debe ser válido',
          );
        }
      }

      // Verificar que todas las tareas existen
      for (final taskId in taskIds) {
        final existingTask = await _repository.getTaskById(taskId);
        if (existingTask == null) {
          throw CacheFailure(message: 'Tarea con ID $taskId no encontrada');
        }
      }

      // Eliminar cada tarea
      for (final taskId in taskIds) {
        await _repository.deleteTask(taskId);
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(
        message: 'Error al eliminar múltiples tareas: $e',
      );
    }
  }
}

/// Use case para eliminar todas las tareas completadas
class DeleteCompletedTasks implements UseCase<int, NoParams> {
  final TaskRepository _repository;

  DeleteCompletedTasks(this._repository);

  @override
  Future<int> call(NoParams params) async {
    try {
      // Obtener estadísticas antes de eliminar
      final statsBefore = await _repository.getTaskStats();

      if (statsBefore.completed == 0) {
        return 0; // No hay tareas completadas para eliminar
      }

      // Eliminar tareas completadas
      final deletedCount = await _repository.deleteCompletedTasks();

      return deletedCount;
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(
        message: 'Error al eliminar tareas completadas: $e',
      );
    }
  }
}

/// Use case para eliminar tareas por rango de fechas
class DeleteTasksByDateRange implements UseCase<int, DateRangeParams> {
  final TaskRepository _repository;

  DeleteTasksByDateRange(this._repository);

  @override
  Future<int> call(DateRangeParams params) async {
    try {
      // Validar parámetros
      _validateParams(params);

      // Obtener tareas en el rango de fechas
      final tasksInRange = await _repository.getTasksByDateRange(
        params.startDate,
        params.endDate,
      );

      if (tasksInRange.isEmpty) {
        return 0; // No hay tareas en el rango
      }

      // Eliminar cada tarea
      int deletedCount = 0;
      for (final task in tasksInRange) {
        if (task.id != null) {
          await _repository.deleteTask(task.id!);
          deletedCount++;
        }
      }

      return deletedCount;
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(
        message: 'Error al eliminar tareas por rango de fechas: $e',
      );
    }
  }

  /// Validar parámetros de entrada
  void _validateParams(DateRangeParams params) {
    if (params.startDate.isAfter(params.endDate)) {
      throw const CacheFailure(
        message: 'La fecha de inicio debe ser anterior a la fecha de fin',
      );
    }

    final now = DateTime.now();
    if (params.startDate.isAfter(now) || params.endDate.isAfter(now)) {
      throw const CacheFailure(message: 'Las fechas no pueden ser futuras');
    }

    final daysDifference = params.endDate.difference(params.startDate).inDays;
    if (daysDifference > 365) {
      throw const CacheFailure(
        message: 'El rango de fechas no puede exceder 365 días',
      );
    }
  }
}

/// Parámetros para rango de fechas
class DateRangeParams {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeParams({required this.startDate, required this.endDate});

  @override
  String toString() {
    return 'DateRangeParams(startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRangeParams &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    return startDate.hashCode ^ endDate.hashCode;
  }
}

/// Use case para eliminar tareas con confirmación
class DeleteTaskWithConfirmation implements UseCase<void, DeleteTaskParams> {
  final TaskRepository _repository;

  DeleteTaskWithConfirmation(this._repository);

  @override
  Future<void> call(DeleteTaskParams params) async {
    try {
      // Validar parámetros
      _validateParams(params);

      // Obtener la tarea para mostrar información
      final task = await _repository.getTaskById(params.id);
      if (task == null) {
        throw const CacheFailure(message: 'Tarea no encontrada');
      }

      // Verificar si la tarea está completada (para tareas importantes)
      if (!params.force && task.isCompleted) {
        // Aquí podrías agregar lógica adicional de confirmación
        // Por ejemplo, verificar si la tarea es importante o tiene dependencias
      }

      // Eliminar a través del repositorio
      await _repository.deleteTask(params.id);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(
        message: 'Error al eliminar tarea con confirmación: $e',
      );
    }
  }

  /// Validar parámetros de entrada
  void _validateParams(DeleteTaskParams params) {
    if (params.id <= 0) {
      throw const CacheFailure(message: 'El ID de la tarea debe ser válido');
    }
  }
}
