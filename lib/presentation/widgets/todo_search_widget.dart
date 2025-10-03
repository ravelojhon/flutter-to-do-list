import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

/// Widget para buscar tareas
class TodoSearchWidget extends ConsumerWidget {
  const TodoSearchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoListState = ref.watch(todoListProvider);
    final todoListNotifier = ref.read(todoListProvider.notifier);

    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar tareas...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            todoListState.searchQuery != null &&
                todoListState.searchQuery!.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => todoListNotifier.searchTodos(''),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      onChanged: (value) {
        todoListNotifier.searchTodos(value);
      },
      textInputAction: TextInputAction.search,
    );
  }
}
