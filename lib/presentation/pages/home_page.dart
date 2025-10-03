import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_list_widget.dart';
import '../widgets/todo_stats_widget.dart';
import '../widgets/todo_filter_widget.dart';
import '../widgets/todo_search_widget.dart';
import '../widgets/add_todo_fab.dart';

/// Página principal de la aplicación
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoListState = ref.watch(todoListProvider);
    final todoListNotifier = ref.read(todoListProvider.notifier);

    // Cargar tareas al inicializar
    ref.listen(todoListProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Cerrar',
              onPressed: () => todoListNotifier.clearError(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Lista de Tareas'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => todoListNotifier.loadTodos(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Estadísticas
          const TodoStatsWidget(),

          // Filtros y búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const TodoSearchWidget(),
                const SizedBox(height: 16),
                const TodoFilterWidget(),
              ],
            ),
          ),

          // Lista de tareas
          Expanded(
            child: todoListState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const TodoListWidget(),
          ),
        ],
      ),
      floatingActionButton: const AddTodoFab(),
    );
  }
}
