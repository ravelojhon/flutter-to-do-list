import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import 'task_list_notifier.dart';

/// Ejemplo simple de uso del TaskListNotifier
class TaskListNotifierUsageExample extends ConsumerWidget {
  const TaskListNotifierUsageExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener el estado actual
    final taskListState = ref.watch(taskListNotifierProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(taskListErrorProvider);
    final stats = ref.watch(taskListStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List Notifier Usage'),
        actions: [
          IconButton(
            onPressed: () {
              // Ejemplo de cómo usar el notifier
              // ref.read(taskListNotifierProvider.notifier).loadTasks();
            },
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
          Expanded(child: _buildTaskList(taskListState.tasks)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ejemplo de cómo agregar una tarea
          // final newTask = Task(
          //   id: null,
          //   title: 'Nueva tarea',
          //   isCompleted: false,
          //   createdAt: DateTime.now(),
          // );
          // ref.read(taskListNotifierProvider.notifier).addTask(newTask);
        },
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
              onPressed: () {
                // Limpiar error
                // ref.read(taskListNotifierProvider.notifier).clearError();
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir lista de tareas
  Widget _buildTaskList(List<Task> tasks) {
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
        return _buildTaskItem(task);
      },
    );
  }

  /// Construir item de tarea
  Widget _buildTaskItem(Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            // Ejemplo de cómo marcar tarea como completada/pendiente
            // if (value == true) {
            //   ref.read(taskListNotifierProvider.notifier).markTaskAsCompleted(task.id!);
            // } else {
            //   ref.read(taskListNotifierProvider.notifier).markTaskAsPending(task.id!);
            // }
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
          onSelected: (value) {
            // Ejemplo de cómo manejar acciones de tarea
            // switch (value) {
            //   case 'edit':
            //     _showEditTaskDialog(task);
            //     break;
            //   case 'delete':
            //     ref.read(taskListNotifierProvider.notifier).deleteTask(task.id!);
            //     break;
            // }
          },
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

  /// Formatear fecha
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Ejemplo de cómo usar los providers derivados
class TaskListProvidersExample extends ConsumerWidget {
  const TaskListProvidersExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar providers derivados
    final tasks = ref.watch(tasksProvider);
    final stats = ref.watch(taskListStatsProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(taskListErrorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Providers Example')),
      body: Column(
        children: [
          // Mostrar estadísticas
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Total: ${stats.total}'),
                  Text('Completadas: ${stats.completed}'),
                  Text('Pendientes: ${stats.pending}'),
                  Text(
                    'Progreso: ${stats.completionPercentage.toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),
          ),

          // Mostrar estado de carga
          if (isLoading) const LinearProgressIndicator(),

          // Mostrar error
          if (error != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Text('Error: $error'),
            ),

          // Mostrar tareas
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(
                    'ID: ${task.id}, Completada: ${task.isCompleted}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Ejemplo de cómo usar el notifier directamente
class TaskListNotifierDirectExample extends ConsumerWidget {
  const TaskListNotifierDirectExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Direct Notifier Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Ejemplo de uso directo del TaskListNotifier'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Ejemplo de cómo usar el notifier directamente
                // final notifier = ref.read(taskListNotifierProvider.notifier);
                // notifier.loadTasks();
              },
              child: const Text('Cargar Tareas'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Ejemplo de cómo agregar una tarea
                // final notifier = ref.read(taskListNotifierProvider.notifier);
                // final newTask = Task(
                //   id: null,
                //   title: 'Tarea de ejemplo',
                //   isCompleted: false,
                //   createdAt: DateTime.now(),
                // );
                // notifier.addTask(newTask);
              },
              child: const Text('Agregar Tarea'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Ejemplo de cómo limpiar error
                // final notifier = ref.read(taskListNotifierProvider.notifier);
                // notifier.clearError();
              },
              child: const Text('Limpiar Error'),
            ),
          ],
        ),
      ),
    );
  }
}
