import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/todo.dart';
import '../providers/todo_provider.dart';

/// Widget para mostrar un elemento individual de tarea
class TodoItemWidget extends ConsumerWidget {
  final Todo todo;

  const TodoItemWidget({super.key, required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoListNotifier = ref.read(todoListProvider.notifier);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) {
            if (value == true) {
              // Marcar como completada
              // En una implementación real, llamarías al use case
            } else {
              // Marcar como pendiente
              // En una implementación real, llamarías al use case
            }
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey[600] : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description != null && todo.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  todo.description!,
                  style: TextStyle(
                    color: todo.isCompleted
                        ? Colors.grey[500]
                        : Colors.grey[700],
                    decoration: todo.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            if (todo.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: todo.isOverdue ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(todo.dueDate!),
                      style: TextStyle(
                        color: todo.isOverdue ? Colors.red : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            if (todo.category != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Chip(
                  label: Text(
                    todo.category!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getCategoryColor(todo.category!),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editTodo(context);
                break;
              case 'delete':
                _deleteTodo(context, ref);
                break;
            }
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
        onTap: () {
          // Toggle completado
          if (todo.isCompleted) {
            // Marcar como pendiente
          } else {
            // Marcar como completada
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Mañana';
    } else if (difference == -1) {
      return 'Ayer';
    } else if (difference > 0) {
      return 'En $difference días';
    } else {
      return 'Hace ${-difference} días';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'trabajo':
        return Colors.blue[100]!;
      case 'personal':
        return Colors.green[100]!;
      case 'compras':
        return Colors.orange[100]!;
      case 'salud':
        return Colors.red[100]!;
      case 'educación':
        return Colors.purple[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  void _editTodo(BuildContext context) {
    // Implementar edición de tarea
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de edición en desarrollo')),
    );
  }

  void _deleteTodo(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Estás seguro de que quieres eliminar "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Implementar eliminación
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de eliminación en desarrollo'),
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
