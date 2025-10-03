import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/todo.dart';
import '../providers/todo_provider.dart';
import 'todo_item_widget.dart';

/// Widget para mostrar la lista de tareas
class TodoListWidget extends ConsumerWidget {
  const TodoListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTodos = ref.watch(filteredTodosProvider);
    final todoListState = ref.watch(todoListProvider);

    if (filteredTodos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(todoListState.filter),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(todoListState.filter, todoListState.searchQuery),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (todoListState.searchQuery != null &&
                todoListState.searchQuery!.isNotEmpty)
              const SizedBox(height: 8),
            if (todoListState.searchQuery != null &&
                todoListState.searchQuery!.isNotEmpty)
              Text(
                'Intenta con otros términos de búsqueda',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredTodos.length,
      itemBuilder: (context, index) {
        final todo = filteredTodos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TodoItemWidget(todo: todo),
        );
      },
    );
  }

  IconData _getEmptyIcon(TodoFilter? filter) {
    switch (filter) {
      case TodoFilter.completed:
        return Icons.check_circle_outline;
      case TodoFilter.pending:
        return Icons.pending_outlined;
      case TodoFilter.overdue:
        return Icons.warning_outlined;
      case TodoFilter.all:
      case null:
        return Icons.task_alt_outlined;
    }
  }

  String _getEmptyMessage(TodoFilter? filter, String? searchQuery) {
    if (searchQuery != null && searchQuery.isNotEmpty) {
      return 'No se encontraron tareas que coincidan con "$searchQuery"';
    }

    switch (filter) {
      case TodoFilter.completed:
        return 'No hay tareas completadas';
      case TodoFilter.pending:
        return 'No hay tareas pendientes';
      case TodoFilter.overdue:
        return 'No hay tareas vencidas';
      case TodoFilter.all:
      case null:
        return 'No hay tareas. ¡Agrega tu primera tarea!';
    }
  }
}
