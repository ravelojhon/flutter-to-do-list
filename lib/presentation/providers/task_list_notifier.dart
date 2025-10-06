import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';

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
    return TaskListState(
      isLoading: false,
      tasks: newTasks,
      error: null,
    );
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
    return TaskListState(
      isLoading: isLoading,
      tasks: tasks,
      error: null,
    );
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
  TaskListNotifier() : super(const TaskListState()) {
    _loadInitialTasks();
  }

  /// Cargar tareas iniciales de demostración
  void _loadInitialTasks() {
    final initialTasks = [
      Task(
        id: 1,
        title: 'Implementar TaskListScreen',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Task(
        id: 2,
        title: 'Configurar Riverpod providers',
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Task(
        id: 3,
        title: 'Crear widgets con Material 3',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Task(
        id: 4,
        title: 'Implementar funcionalidad de eliminar',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      Task(
        id: 5,
        title: 'Agregar validaciones de entrada',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];

    state = state.withTasks(initialTasks);
  }

  /// Cargar todas las tareas (simulado)
  Future<void> loadTasks() async {
    try {
      state = state.loading();
      
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 800));
      
      _loadInitialTasks();
    } catch (e) {
      state = state.withError('Error al cargar tareas: $e');
    }
  }

  /// Agregar nueva tarea
  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) {
      state = state.withError('El título de la tarea no puede estar vacío');
      return;
    }

    try {
      state = state.loading();
      
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));
      
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title.trim(),
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      
      state = state.withTaskAdded(newTask);
    } catch (e) {
      state = state.withError('Error al agregar tarea: $e');
    }
  }

  /// Actualizar tarea existente
  Future<void> updateTask(Task task) async {
    try {
      state = state.loading();
      
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 300));
      
      state = state.withTaskUpdated(task);
    } catch (e) {
      state = state.withError('Error al actualizar tarea: $e');
    }
  }

  /// Eliminar tarea por ID
  Future<void> deleteTask(int taskId) async {
    try {
      state = state.loading();
      
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 300));
      
      state = state.withTaskDeleted(taskId);
    } catch (e) {
      state = state.withError('Error al eliminar tarea: $e');
    }
  }

  /// Marcar tarea como completada
  Future<void> markTaskAsCompleted(int taskId) async {
    try {
      state = state.loading();
      
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 200));
      
      final task = state.tasks.firstWhere((task) => task.id == taskId);
      final updatedTask = task.markAsCompleted();
      
      state = state.withTaskUpdated(updatedTask);
    } catch (e) {
      state = state.withError('Error al marcar tarea como completada: $e');
    }
  }

  /// Marcar tarea como pendiente
  Future<void> markTaskAsPending(int taskId) async {
    try {
      state = state.loading();
      
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 200));
      
      final task = state.tasks.firstWhere((task) => task.id == taskId);
      final updatedTask = task.markAsPending();
      
      state = state.withTaskUpdated(updatedTask);
    } catch (e) {
      state = state.withError('Error al marcar tarea como pendiente: $e');
    }
  }

  /// Actualizar título de tarea
  Future<void> updateTaskTitle(int taskId, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      state = state.withError('El título de la tarea no puede estar vacío');
      return;
    }

    try {
      state = state.loading();
      
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 300));
      
      final task = state.tasks.firstWhere((task) => task.id == taskId);
      final updatedTask = task.updateTitle(newTitle.trim());
      
      state = state.withTaskUpdated(updatedTask);
    } catch (e) {
      state = state.withError('Error al actualizar título: $e');
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
}

/// Provider para el TaskListNotifier
final taskListNotifierProvider =
    StateNotifierProvider<TaskListNotifier, TaskListState>((ref) {
  return TaskListNotifier();
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