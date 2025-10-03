import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';

/// Parámetros para actualizar una tarea
class UpdateTaskParams {
  final int id;
  final String? title;
  final bool? isCompleted;
  final DateTime? updatedAt;

  const UpdateTaskParams({
    required this.id,
    this.title,
    this.isCompleted,
    this.updatedAt,
  });

  /// Crear UpdateTaskParams desde una Task existente
  factory UpdateTaskParams.fromTask(Task task) {
    if (task.id == null) {
      throw const CacheFailure(
        message: 'La tarea debe tener un ID para ser actualizada',
      );
    }

    return UpdateTaskParams(
      id: task.id!,
      title: task.title,
      isCompleted: task.isCompleted,
      updatedAt: task.updatedAt,
    );
  }

  /// Crear UpdateTaskParams para actualizar solo el título
  factory UpdateTaskParams.updateTitle(int id, String title) {
    return UpdateTaskParams(id: id, title: title, updatedAt: DateTime.now());
  }

  /// Crear UpdateTaskParams para marcar como completada
  factory UpdateTaskParams.markAsCompleted(int id) {
    return UpdateTaskParams(
      id: id,
      isCompleted: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Crear UpdateTaskParams para marcar como pendiente
  factory UpdateTaskParams.markAsPending(int id) {
    return UpdateTaskParams(
      id: id,
      isCompleted: false,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'UpdateTaskParams(id: $id, title: $title, isCompleted: $isCompleted, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateTaskParams &&
        other.id == id &&
        other.title == title &&
        other.isCompleted == isCompleted &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        isCompleted.hashCode ^
        updatedAt.hashCode;
  }
}

/// Use case para actualizar una tarea
class UpdateTask implements UseCase<void, UpdateTaskParams> {
  final TaskRepository _repository;

  UpdateTask(this._repository);

  @override
  Future<void> call(UpdateTaskParams params) async {
    try {
      // Validar parámetros
      _validateParams(params);

      // Obtener la tarea existente
      final existingTask = await _repository.getTaskById(params.id);
      if (existingTask == null) {
        throw const CacheFailure(message: 'Tarea no encontrada');
      }

      // Crear la tarea actualizada
      final updatedTask = existingTask.copyWith(
        title: params.title ?? existingTask.title,
        isCompleted: params.isCompleted ?? existingTask.isCompleted,
        updatedAt: params.updatedAt ?? DateTime.now(),
      );

      // Actualizar a través del repositorio
      await _repository.updateTask(updatedTask);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(message: 'Error al actualizar tarea: $e');
    }
  }

  /// Validar parámetros de entrada
  void _validateParams(UpdateTaskParams params) {
    if (params.id <= 0) {
      throw const CacheFailure(message: 'El ID de la tarea debe ser válido');
    }

    if (params.title != null && params.title!.trim().isEmpty) {
      throw const CacheFailure(
        message: 'El título de la tarea no puede estar vacío',
      );
    }

    if (params.title != null && params.title!.length > 200) {
      throw const CacheFailure(
        message: 'El título de la tarea no puede exceder 200 caracteres',
      );
    }

    if (params.updatedAt != null && params.updatedAt!.isAfter(DateTime.now())) {
      throw const CacheFailure(
        message: 'La fecha de actualización no puede ser futura',
      );
    }
  }
}

/// Use case para actualizar solo el título de una tarea
class UpdateTaskTitle implements UseCase<void, UpdateTaskParams> {
  final TaskRepository _repository;

  UpdateTaskTitle(this._repository);

  @override
  Future<void> call(UpdateTaskParams params) async {
    try {
      if (params.title == null || params.title!.trim().isEmpty) {
        throw const CacheFailure(
          message: 'El título de la tarea no puede estar vacío',
        );
      }

      if (params.title!.length > 200) {
        throw const CacheFailure(
          message: 'El título de la tarea no puede exceder 200 caracteres',
        );
      }

      // Actualizar solo el título usando el método específico del repositorio
      await _repository.updateTaskTitle(params.id, params.title!.trim());
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(
        message: 'Error al actualizar título de tarea: $e',
      );
    }
  }
}

/// Use case para marcar tarea como completada
class MarkTaskAsCompleted implements UseCase<void, int> {
  final TaskRepository _repository;

  MarkTaskAsCompleted(this._repository);

  @override
  Future<void> call(int taskId) async {
    try {
      if (taskId <= 0) {
        throw const CacheFailure(message: 'El ID de la tarea debe ser válido');
      }

      await _repository.markTaskAsCompleted(taskId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(
        message: 'Error al marcar tarea como completada: $e',
      );
    }
  }
}

/// Use case para marcar tarea como pendiente
class MarkTaskAsPending implements UseCase<void, int> {
  final TaskRepository _repository;

  MarkTaskAsPending(this._repository);

  @override
  Future<void> call(int taskId) async {
    try {
      if (taskId <= 0) {
        throw const CacheFailure(message: 'El ID de la tarea debe ser válido');
      }

      await _repository.markTaskAsPending(taskId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(
        message: 'Error al marcar tarea como pendiente: $e',
      );
    }
  }
}

/// Use case para actualizar múltiples tareas
class UpdateMultipleTasks implements UseCase<void, List<UpdateTaskParams>> {
  final TaskRepository _repository;

  UpdateMultipleTasks(this._repository);

  @override
  Future<void> call(List<UpdateTaskParams> params) async {
    try {
      if (params.isEmpty) {
        throw const CacheFailure(
          message: 'No se pueden actualizar tareas vacías',
        );
      }

      if (params.length > 50) {
        throw const CacheFailure(
          message: 'No se pueden actualizar más de 50 tareas a la vez',
        );
      }

      // Validar cada parámetro
      for (final param in params) {
        _validateParams(param);
      }

      // Actualizar cada tarea
      for (final param in params) {
        await UpdateTask(_repository).call(param);
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(
        message: 'Error al actualizar múltiples tareas: $e',
      );
    }
  }

  /// Validar parámetros de entrada
  void _validateParams(UpdateTaskParams params) {
    if (params.id <= 0) {
      throw const CacheFailure(message: 'El ID de la tarea debe ser válido');
    }

    if (params.title != null && params.title!.trim().isEmpty) {
      throw const CacheFailure(
        message: 'El título de la tarea no puede estar vacío',
      );
    }

    if (params.title != null && params.title!.length > 200) {
      throw const CacheFailure(
        message: 'El título de la tarea no puede exceder 200 caracteres',
      );
    }
  }
}
