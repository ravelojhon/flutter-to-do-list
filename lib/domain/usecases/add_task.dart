import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';

/// Parámetros para agregar una tarea
class AddTaskParams {
  final String title;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AddTaskParams({
    required this.title,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Crear AddTaskParams desde una Task existente
  factory AddTaskParams.fromTask(Task task) {
    return AddTaskParams(
      title: task.title,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  /// Convertir a Task
  Task toTask() {
    return Task(
      id: null, // Se generará automáticamente
      title: title,
      isCompleted: isCompleted,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'AddTaskParams(title: $title, isCompleted: $isCompleted, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddTaskParams &&
        other.title == title &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        isCompleted.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

/// Use case para agregar una nueva tarea
class AddTask implements UseCase<void, AddTaskParams> {
  final TaskRepository _repository;

  AddTask(this._repository);

  @override
  Future<void> call(AddTaskParams params) async {
    try {
      // Validar parámetros
      _validateParams(params);

      // Crear la tarea
      final task = params.toTask();

      // Agregar a través del repositorio
      await _repository.addTask(task);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(message: 'Error al agregar tarea: $e');
    }
  }

  /// Validar parámetros de entrada
  void _validateParams(AddTaskParams params) {
    if (params.title.trim().isEmpty) {
      throw const CacheFailure(
        message: 'El título de la tarea no puede estar vacío',
      );
    }

    if (params.title.length > 200) {
      throw const CacheFailure(
        message: 'El título de la tarea no puede exceder 200 caracteres',
      );
    }

    if (params.createdAt != null && params.createdAt!.isAfter(DateTime.now())) {
      throw const CacheFailure(
        message: 'La fecha de creación no puede ser futura',
      );
    }

    if (params.updatedAt != null && params.updatedAt!.isAfter(DateTime.now())) {
      throw const CacheFailure(
        message: 'La fecha de actualización no puede ser futura',
      );
    }

    if (params.createdAt != null && params.updatedAt != null) {
      if (params.updatedAt!.isBefore(params.createdAt!)) {
        throw const CacheFailure(
          message:
              'La fecha de actualización no puede ser anterior a la fecha de creación',
        );
      }
    }
  }
}

/// Use case para agregar múltiples tareas
class AddMultipleTasks implements UseCase<void, List<AddTaskParams>> {
  final TaskRepository _repository;

  AddMultipleTasks(this._repository);

  @override
  Future<void> call(List<AddTaskParams> params) async {
    try {
      if (params.isEmpty) {
        throw const CacheFailure(message: 'No se pueden agregar tareas vacías');
      }

      if (params.length > 100) {
        throw const CacheFailure(
          message: 'No se pueden agregar más de 100 tareas a la vez',
        );
      }

      // Validar cada parámetro
      for (final param in params) {
        _validateParams(param);
      }

      // Agregar cada tarea
      for (final param in params) {
        final task = param.toTask();
        await _repository.addTask(task);
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(message: 'Error al agregar múltiples tareas: $e');
    }
  }

  /// Validar parámetros de entrada
  void _validateParams(AddTaskParams params) {
    if (params.title.trim().isEmpty) {
      throw const CacheFailure(
        message: 'El título de la tarea no puede estar vacío',
      );
    }

    if (params.title.length > 200) {
      throw const CacheFailure(
        message: 'El título de la tarea no puede exceder 200 caracteres',
      );
    }
  }
}

/// Use case para agregar tarea con validaciones específicas
class AddTaskWithValidation implements UseCase<void, AddTaskParams> {
  final TaskRepository _repository;

  AddTaskWithValidation(this._repository);

  @override
  Future<void> call(AddTaskParams params) async {
    try {
      // Validaciones básicas
      _validateBasicParams(params);

      // Verificar si ya existe una tarea con el mismo título
      final existingTasks = await _repository.searchTasks(params.title);
      if (existingTasks.isNotEmpty) {
        throw const CacheFailure(
          message: 'Ya existe una tarea con el mismo título',
        );
      }

      // Crear la tarea
      final task = params.toTask();

      // Agregar a través del repositorio
      await _repository.addTask(task);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnexpectedFailure(
        message: 'Error al agregar tarea con validación: $e',
      );
    }
  }

  /// Validar parámetros básicos
  void _validateBasicParams(AddTaskParams params) {
    if (params.title.trim().isEmpty) {
      throw const CacheFailure(
        message: 'El título de la tarea no puede estar vacío',
      );
    }

    if (params.title.length > 200) {
      throw const CacheFailure(
        message: 'El título de la tarea no puede exceder 200 caracteres',
      );
    }
  }
}
