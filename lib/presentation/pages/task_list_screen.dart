import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../providers/task_list_notifier.dart';

/// Pantalla principal para mostrar la lista de tareas
class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar tareas al inicializar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskListNotifierProvider.notifier).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskListState = ref.watch(taskListNotifierProvider);
    final notifier = ref.read(taskListNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => notifier.refresh(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, notifier),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter_pending',
                child: Row(
                  children: [
                    Icon(Icons.pending, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Solo Pendientes'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'filter_completed',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Solo Completadas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'filter_all',
                child: Row(
                  children: [
                    Icon(Icons.list, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Todas las Tareas'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Estadísticas
          _buildStatsCard(taskListState.stats),
          
          // Widget de error
          if (taskListState.hasError) _buildErrorCard(taskListState.error!, notifier),
          
          // Indicador de carga
          if (taskListState.isLoading) const LinearProgressIndicator(),
          
          // Lista de tareas
          Expanded(
            child: _buildTaskList(taskListState.tasks, notifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context, notifier),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Tarea'),
      ),
    );
  }

  /// Construir tarjeta de estadísticas
  Widget _buildStatsCard(TaskListStats stats) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total',
              stats.total.toString(),
              Icons.list_alt,
              Colors.blue,
            ),
            _buildStatItem(
              'Completadas',
              stats.completed.toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatItem(
              'Pendientes',
              stats.pending.toString(),
              Icons.pending,
              Colors.orange,
            ),
            _buildStatItem(
              'Progreso',
              '${stats.completionPercentage.toStringAsFixed(1)}%',
              Icons.trending_up,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  /// Construir item de estadística
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  /// Construir tarjeta de error
  Widget _buildErrorCard(String error, TaskListNotifier notifier) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            IconButton(
              onPressed: () => notifier.clearError(),
              icon: Icon(Icons.close, color: Colors.red.shade700),
              tooltip: 'Cerrar error',
            ),
          ],
        ),
      ),
    );
  }

  /// Construir lista de tareas
  Widget _buildTaskList(List<Task> tasks, TaskListNotifier notifier) {
    if (tasks.isEmpty) {
      return _buildEmptyState(notifier);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await notifier.refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskItem(task, notifier);
        },
      ),
    );
  }

  /// Construir item de tarea
  Widget _buildTaskItem(Task task, TaskListNotifier notifier) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) {
            if (value == true) {
              notifier.markTaskAsCompleted(task.id!);
            } else {
              notifier.markTaskAsPending(task.id!);
            }
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
            fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  task.isCompleted ? Icons.check_circle : Icons.pending,
                  size: 16,
                  color: task.isCompleted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  task.statusText,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Creada: ${_formatDate(task.createdAt)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            if (task.updatedAt != null)
              Text(
                'Actualizada: ${_formatDate(task.updatedAt!)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleTaskAction(value, task, notifier),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
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

  /// Construir estado vacío
  Widget _buildEmptyState(TaskListNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay tareas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para agregar una nueva tarea',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddTaskDialog(context, notifier),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Primera Tarea'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo para agregar tarea
  void _showAddTaskDialog(BuildContext context, TaskListNotifier notifier) {
    final titleController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Tarea'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Título de la tarea',
            border: OutlineInputBorder(),
            hintText: 'Escribe el título de la tarea...',
          ),
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                notifier.addTask(titleController.text.trim());
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Tarea agregada exitosamente'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo para editar tarea
  void _showEditTaskDialog(Task task, TaskListNotifier notifier) {
    final titleController = TextEditingController(text: task.title);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Tarea'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Título de la tarea',
            border: OutlineInputBorder(),
            hintText: 'Escribe el nuevo título...',
          ),
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                notifier.updateTaskTitle(task.id!, titleController.text.trim());
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Tarea actualizada exitosamente'),
                    backgroundColor: Colors.blue,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar confirmación de eliminación
  void _showDeleteConfirmation(Task task, TaskListNotifier notifier) {
    showDialog(
      context: context,
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
              notifier.deleteTask(task.id!);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Tarea eliminada exitosamente'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Manejar acciones de tarea
  void _handleTaskAction(String action, Task task, TaskListNotifier notifier) {
    switch (action) {
      case 'edit':
        _showEditTaskDialog(task, notifier);
        break;
      case 'delete':
        _showDeleteConfirmation(task, notifier);
        break;
    }
  }

  /// Manejar acciones del menú
  void _handleMenuAction(String action, TaskListNotifier notifier) {
    switch (action) {
      case 'filter_pending':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filtro: Solo pendientes')),
        );
        break;
      case 'filter_completed':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filtro: Solo completadas')),
        );
        break;
      case 'filter_all':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filtro: Todas las tareas')),
        );
        break;
    }
  }

  /// Formatear fecha
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

