import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart' as domain;
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/task_repository_impl.dart';
import 'task_list_notifier.dart';

/// Ejemplo de uso del TaskListNotifier
class TaskListNotifierExample extends ConsumerWidget {
  const TaskListNotifierExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener el estado actual
    final taskListState = ref.watch(taskListNotifierProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(taskListErrorProvider);
    final stats = ref.watch(taskListStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List Notifier Example'),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(taskListNotifierProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Estadísticas
          _buildStatsCard(stats),

          // Error message
          if (error != null) _buildErrorCard(error, ref),

          // Loading indicator
          if (isLoading) const LinearProgressIndicator(),

          // Lista de tareas
          Expanded(child: _buildTaskList(taskListState.tasks, ref)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Construir tarjeta de estadísticas
  Widget _buildStatsCard(TaskListStats stats) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', stats.total.toString()),
                _buildStatItem('Completadas', stats.completed.toString()),
                _buildStatItem('Pendientes', stats.pending.toString()),
                _buildStatItem(
                  'Progreso',
                  '${stats.completionPercentage.toStringAsFixed(1)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construir item de estadística
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  /// Construir tarjeta de error
  Widget _buildErrorCard(String error, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(error, style: TextStyle(color: Colors.red.shade700)),
            ),
            IconButton(
              onPressed: () =>
                  ref.read(taskListNotifierProvider.notifier).clearError(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir lista de tareas
  Widget _buildTaskList(List<domain.Task> tasks, WidgetRef ref) {
    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay tareas',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Toca el botón + para agregar una tarea',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskItem(task, ref);
      },
    );
  }

  /// Construir item de tarea
  Widget _buildTaskItem(domain.Task task, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            if (value == true) {
              ref
                  .read(taskListNotifierProvider.notifier)
                  .markTaskAsCompleted(task.id!);
            } else {
              ref
                  .read(taskListNotifierProvider.notifier)
                  .markTaskAsPending(task.id!);
            }
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Creada: ${_formatDate(task.createdAt)}'),
            if (task.updatedAt != null)
              Text('Actualizada: ${_formatDate(task.updatedAt!)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleTaskAction(value, task, ref),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Manejar acción de tarea
  void _handleTaskAction(String action, domain.Task task, WidgetRef ref) {
    switch (action) {
      case 'edit':
        _showEditTaskDialog(task, ref);
        break;
      case 'delete':
        _showDeleteConfirmation(task, ref);
        break;
    }
  }

  /// Mostrar diálogo para agregar tarea
  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Tarea'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Título de la tarea',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                final newTask = domain.Task(
                  id: null,
                  title: titleController.text.trim(),
                  isCompleted: false,
                  createdAt: DateTime.now(),
                );
                ref.read(taskListNotifierProvider.notifier).addTask(newTask);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo para editar tarea
  void _showEditTaskDialog(domain.Task task, WidgetRef ref) {
    final titleController = TextEditingController(text: task.title);

    showDialog(
      context: ref.context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Tarea'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Título de la tarea',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                final updatedTask = task.copyWith(
                  title: titleController.text.trim(),
                  updatedAt: DateTime.now(),
                );
                ref
                    .read(taskListNotifierProvider.notifier)
                    .updateTask(updatedTask);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar confirmación de eliminación
  void _showDeleteConfirmation(domain.Task task, WidgetRef ref) {
    showDialog(
      context: ref.context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tarea'),
        content: Text('¿Estás seguro de que quieres eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(taskListNotifierProvider.notifier).deleteTask(task.id!);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Formatear fecha
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Provider personalizado para el TaskListNotifier con dependencias inyectadas
final taskListNotifierWithDependenciesProvider =
    StateNotifierProvider<TaskListNotifier, TaskListState>((ref) {
      // Crear instancias de las dependencias
      final database = AppDatabase();
      final repository = TaskRepositoryImpl(database);

      // Crear use cases
      final getTasks = GetTasks(repository);
      final addTask = AddTask(repository);
      final updateTask = UpdateTask(repository);
      final deleteTask = DeleteTask(repository);

      return TaskListNotifier(
        getTasks: getTasks,
        addTask: addTask,
        updateTask: updateTask,
        deleteTask: deleteTask,
      );
    });

/// Ejemplo de uso básico del TaskListNotifier
class TaskListNotifierBasicExample extends ConsumerWidget {
  const TaskListNotifierBasicExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListState = ref.watch(taskListNotifierWithDependenciesProvider);
    final notifier = ref.read(
      taskListNotifierWithDependenciesProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List Basic Example'),
        actions: [
          IconButton(
            onPressed: () => notifier.loadTasks(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Botones de acción
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => notifier.loadTasks(),
                  child: const Text('Cargar Tareas'),
                ),
                ElevatedButton(
                  onPressed: () => _addSampleTask(notifier),
                  child: const Text('Agregar Ejemplo'),
                ),
                ElevatedButton(
                  onPressed: () => notifier.clearError(),
                  child: const Text('Limpiar Error'),
                ),
              ],
            ),
          ),

          // Estado de carga
          if (taskListState.isLoading) const LinearProgressIndicator(),

          // Error
          if (taskListState.error != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Text(
                taskListState.error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),

          // Lista de tareas
          Expanded(
            child: ListView.builder(
              itemCount: taskListState.tasks.length,
              itemBuilder: (context, index) {
                final task = taskListState.tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(
                    'ID: ${task.id}, Completada: ${task.isCompleted}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => notifier.markTaskAsCompleted(task.id!),
                        icon: const Icon(Icons.check),
                      ),
                      IconButton(
                        onPressed: () => notifier.deleteTask(task.id!),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Agregar tarea de ejemplo
  void _addSampleTask(TaskListNotifier notifier) {
    final sampleTask = domain.Task(
      id: null,
      title: 'Tarea de ejemplo ${DateTime.now().millisecondsSinceEpoch}',
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    notifier.addTask(sampleTask);
  }
}
