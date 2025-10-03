import '../entities/task.dart';

/// Interfaz del repositorio de tareas
abstract class TaskRepository {
  /// Obtener todas las tareas
  Future<List<Task>> getAllTasks();

  /// Agregar una nueva tarea
  Future<void> addTask(Task task);

  /// Actualizar una tarea existente
  Future<void> updateTask(Task task);

  /// Eliminar una tarea por ID
  Future<void> deleteTask(int id);

  /// Obtener tarea por ID
  Future<Task?> getTaskById(int id);

  /// Obtener tareas por estado
  Future<List<Task>> getTasksByStatus(bool isCompleted);

  /// Buscar tareas por título
  Future<List<Task>> searchTasks(String query);

  /// Obtener tareas recientes
  Future<List<Task>> getRecentTasks(int limit);

  /// Obtener estadísticas de tareas
  Future<TaskStats> getTaskStats();
}

/// Estadísticas de tareas
class TaskStats {
  final int total;
  final int completed;
  final int pending;

  const TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
  });

  double get completionPercentage {
    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }

  @override
  String toString() {
    return 'TaskStats(total: $total, completed: $completed, pending: $pending, completionPercentage: ${completionPercentage.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskStats &&
        other.total == total &&
        other.completed == completed &&
        other.pending == pending;
  }

  @override
  int get hashCode {
    return total.hashCode ^ completed.hashCode ^ pending.hashCode;
  }
}
