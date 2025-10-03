import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

/// Widget para filtrar tareas
class TodoFilterWidget extends ConsumerWidget {
  const TodoFilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoListState = ref.watch(todoListProvider);
    final todoListNotifier = ref.read(todoListProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TodoFilter.values.map((filter) {
          final isSelected = todoListState.filter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  todoListNotifier.filterTodos(filter);
                } else {
                  todoListNotifier.filterTodos(TodoFilter.all);
                }
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFilterLabel(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return 'Todas';
      case TodoFilter.completed:
        return 'Completadas';
      case TodoFilter.pending:
        return 'Pendientes';
      case TodoFilter.overdue:
        return 'Vencidas';
    }
  }
}
