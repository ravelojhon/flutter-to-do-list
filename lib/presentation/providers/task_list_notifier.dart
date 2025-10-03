import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';

/// Estado de la lista de tareas
class TaskListState {
  final bool isLoading;
  final List<Task> tasks;
  final String? error;

  const TaskListState({
    this.isLoading = false,
    this.tasks = const [],
    this.error,
  });

  /// Crear estado de carga
  TaskListState loading() {
    return TaskListState(
      isLoading: true,
      tasks: tasks, // Mantener tareas existentes durante la carga
      error: null,
    );
  }

  /// Crear estado con tareas
  TaskListState withTasks(List<Task> newTasks) {
    return TaskListState(isLoading: false, tasks: newTasks, error: null);
  }

  /// Crear estado con error
  TaskListState withError(String errorMessage) {
    return TaskListState(
      isLoading: false,
      tasks: tasks, // Mantener tareas existentes
      error: errorMessage,
    );
  }

  /// Crear estado con tarea agregada
  TaskListState withTaskAdded(Task newTask) {
    return TaskListState(
      isLoading: false,
      tasks: [...tasks, newTask],
      error: null,
    );
  }

  /// Crear estado con tarea actualizada
  TaskListState withTaskUpdated(Task updatedTask) {
    return TaskListState(
      isLoading: false,
      tasks: tasks
          .map((task) => task.id == updatedTask.id ? updatedTask : task)
          .toList(),
      error: null,
    );
  }

  /// Crear estado con tarea eliminada
  TaskListState withTaskDeleted(int taskId) {
    return TaskListState(
      isLoading: false,
      tasks: tasks.where((task) => task.id != taskId).toList(),
      error: null,
    );
  }

  /// Crear estado con error limpiado
  TaskListState clearError() {
    return TaskListState(isLoading: isLoading, tasks: tasks, error: null);
  }

  /// Verificar si hay tareas
  bool get hasTasks => tasks.isNotEmpty;

  /// Verificar si hay error
  bool get hasError => error != null;

  /// Obtener tareas pendientes
  List<Task> get pendingTasks =>
      tasks.where((task) => !task.isCompleted).toList();

  /// Obtener tareas completadas
  List<Task> get completedTasks =>
      tasks.where((task) => task.isCompleted).toList();

  /// Obtener estadísticas
  TaskListStats get stats {
    final total = tasks.length;
    final completed = completedTasks.length;
    final pending = pendingTasks.length;
    final completionPercentage = total > 0 ? (completed / total) * 100 : 0.0;

    return TaskListStats(
      total: total,
      completed: completed,
      pending: pending,
      completionPercentage: completionPercentage,
    );
  }

  @override
  String toString() {
    return 'TaskListState(isLoading: $isLoading, tasks: ${tasks.length}, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskListState &&
        other.isLoading == isLoading &&
        other.tasks == tasks &&
        other.error == error;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^ tasks.hashCode ^ error.hashCode;
  }
}

/// Estadísticas de la lista de tareas
class TaskListStats {
  final int total;
  final int completed;
  final int pending;
  final double completionPercentage;

  const TaskListStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.completionPercentage,
  });

  @override
  String toString() {
    return 'TaskListStats(total: $total, completed: $completed, pending: $pending, completion: ${completionPercentage.toStringAsFixed(1)}%)';
  }
}

/// Notifier para manejar el estado de la lista de tareas
class TaskListNotifier extends StateNotifier<TaskListState> {
  final GetTasks _getTasks;
  final AddTask _addTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;

  TaskListNotifier({
    required GetTasks getTasks,
    required AddTask addTask,
    required UpdateTask updateTask,
    required DeleteTask deleteTask,
  }) : _getTasks = getTasks,
       _addTask = addTask,
       _updateTask = updateTask,
       _deleteTask = deleteTask,
       super(const TaskListState());

  /// Cargar todas las tareas
  Future<void> loadTasks() async {
    try {
      state = state.loading();

      final tasks = await _getTasks(const NoParams());
      state = state.withTasks(tasks);
    } on Failure catch (failure) {
      state = state.withError(_getErrorMessage(failure));
    } catch (e) {
      state = state.withError('Error inesperado al cargar tareas: $e');
    }
  }

  /// Agregar nueva tarea
  Future<void> addTask(Task task) async {
    try {
      state = state.loading();

      final addTaskParams = AddTaskParams.fromTask(task);
      await _addTask(addTaskParams);

      // Recargar tareas para obtener el ID generado
      await loadTasks();
    } on Failure catch (failure) {
      state = state.withError(_getErrorMessage(failure));
    } catch (e) {
      state = state.withError('Error inesperado al agregar tarea: $e');
    }
  }

  /// Actualizar tarea existente
  Future<void> updateTask(Task task) async {
    try {
      state = state.loading();

      final updateParams = UpdateTaskParams.fromTask(task);
      await _updateTask(updateParams);

      // Actualizar estado local
      state = state.withTaskUpdated(task);
    } on Failure catch (failure) {
      state = state.withError(_getErrorMessage(failure));
    } catch (e) {
      state = state.withError('Error inesperado al actualizar tarea: $e');
    }
  }

  /// Eliminar tarea por ID
  Future<void> deleteTask(int taskId) async {
    try {
      state = state.loading();

      final deleteParams = DeleteTaskParams(id: taskId);
      await _deleteTask(deleteParams);

      // Actualizar estado local
      state = state.withTaskDeleted(taskId);
    } on Failure catch (failure) {
      state = state.withError(_getErrorMessage(failure));
    } catch (e) {
      state = state.withError('Error inesperado al eliminar tarea: $e');
    }
  }

  /// Marcar tarea como completada
  Future<void> markTaskAsCompleted(int taskId) async {
    try {
      state = state.loading();

      final updateParams = UpdateTaskParams.markAsCompleted(taskId);
      await _updateTask(updateParams);

      // Recargar tareas para obtener el estado actualizado
      await loadTasks();
    } on Failure catch (failure) {
      state = state.withError(_getErrorMessage(failure));
    } catch (e) {
      state = state.withError(
        'Error inesperado al marcar tarea como completada: $e',
      );
    }
  }

  /// Marcar tarea como pendiente
  Future<void> markTaskAsPending(int taskId) async {
    try {
      state = state.loading();

      final updateParams = UpdateTaskParams.markAsPending(taskId);
      await _updateTask(updateParams);

      // Recargar tareas para obtener el estado actualizado
      await loadTasks();
    } on Failure catch (failure) {
      state = state.withError(_getErrorMessage(failure));
    } catch (e) {
      state = state.withError(
        'Error inesperado al marcar tarea como pendiente: $e',
      );
    }
  }

  /// Actualizar título de tarea
  Future<void> updateTaskTitle(int taskId, String newTitle) async {
    try {
      state = state.loading();

      final updateParams = UpdateTaskParams.updateTitle(taskId, newTitle);
      await _updateTask(updateParams);

      // Recargar tareas para obtener el título actualizado
      await loadTasks();
    } on Failure catch (failure) {
      state = state.withError(_getErrorMessage(failure));
    } catch (e) {
      state = state.withError('Error inesperado al actualizar título: $e');
    }
  }

  /// Limpiar error
  void clearError() {
    state = state.clearError();
  }

  /// Refrescar lista de tareas
  Future<void> refresh() async {
    await loadTasks();
  }

  /// Obtener mensaje de error legible
  String _getErrorMessage(Failure failure) {
    return failure.when(
      serverFailure: (message, statusCode) => 'Error del servidor: $message',
      cacheFailure: (message) => 'Error de caché: $message',
      networkFailure: (message) => 'Error de conexión: $message',
      validationFailure: (message, fieldErrors) =>
          'Error de validación: $message',
      unknownFailure: (message) => 'Error desconocido: $message',
    );
  }
}

/// Provider para el TaskListNotifier
final taskListNotifierProvider =
    StateNotifierProvider<TaskListNotifier, TaskListState>((ref) {
      // Aquí necesitarías inyectar los use cases
      // Por ahora, se crean instancias vacías para evitar errores de compilación
      throw UnimplementedError('Los use cases deben ser inyectados aquí');
    });

/// Provider para obtener solo las tareas
final tasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskListNotifierProvider).tasks;
});

/// Provider para obtener tareas pendientes
final pendingTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskListNotifierProvider).pendingTasks;
});

/// Provider para obtener tareas completadas
final completedTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskListNotifierProvider).completedTasks;
});

/// Provider para obtener estadísticas
final taskListStatsProvider = Provider<TaskListStats>((ref) {
  return ref.watch(taskListNotifierProvider).stats;
});

/// Provider para verificar si está cargando
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(taskListNotifierProvider).isLoading;
});

/// Provider para obtener el error
final taskListErrorProvider = Provider<String?>((ref) {
  return ref.watch(taskListNotifierProvider).error;
});
