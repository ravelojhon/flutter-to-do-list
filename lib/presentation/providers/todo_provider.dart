import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/todo.dart';
import '../../domain/usecases/get_all_todos.dart';
import '../../domain/usecases/create_todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../data/datasources/todo_local_datasource.dart';

/// Estado de la lista de tareas
@freezed
class TodoListState with _$TodoListState {
  const factory TodoListState({
    @Default([]) List<Todo> todos,
    @Default(false) bool isLoading,
    @Default(false) bool isCreating,
    String? error,
    String? searchQuery,
    TodoFilter? filter,
  }) = _TodoListState;
}

/// Filtros para las tareas
enum TodoFilter { all, completed, pending, overdue }

/// Provider del repositorio de tareas
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  // En una implementación real, aquí inyectarías las dependencias
  // Por ahora, creamos una instancia mock
  throw UnimplementedError('Implementar inyección de dependencias');
});

/// Provider para obtener todas las tareas
final getAllTodosProvider = FutureProvider<List<Todo>>((ref) async {
  final repository = ref.read(todoRepositoryProvider);
  final useCase = GetAllTodos(repository);

  final result = await useCase.call();
  return result.fold(
    (failure) => throw Exception(failure.userMessage),
    (todos) => todos,
  );
});

/// Provider del estado de la lista de tareas
final todoListProvider = StateNotifierProvider<TodoListNotifier, TodoListState>(
  (ref) {
    return TodoListNotifier(ref.read(todoRepositoryProvider));
  },
);

/// Notifier para manejar el estado de la lista de tareas
class TodoListNotifier extends StateNotifier<TodoListState> {
  final TodoRepository _repository;

  TodoListNotifier(this._repository) : super(const TodoListState());

  /// Cargar todas las tareas
  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = GetAllTodos(_repository);
      final result = await useCase.call();

      result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, error: failure.userMessage);
        },
        (todos) {
          state = state.copyWith(isLoading: false, todos: todos, error: null);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error inesperado: $e');
    }
  }

  /// Crear una nueva tarea
  Future<void> createTodo(CreateTodoParams params) async {
    state = state.copyWith(isCreating: true, error: null);

    try {
      final useCase = CreateTodo(_repository);
      final result = await useCase.call(params);

      result.fold(
        (failure) {
          state = state.copyWith(isCreating: false, error: failure.userMessage);
        },
        (todo) {
          state = state.copyWith(
            isCreating: false,
            todos: [...state.todos, todo],
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isCreating: false, error: 'Error inesperado: $e');
    }
  }

  /// Filtrar tareas
  void filterTodos(TodoFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Buscar tareas
  void searchTodos(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Obtener tareas filtradas
  List<Todo> get filteredTodos {
    var todos = state.todos;

    // Aplicar filtro
    switch (state.filter) {
      case TodoFilter.completed:
        todos = todos.where((todo) => todo.isCompleted).toList();
        break;
      case TodoFilter.pending:
        todos = todos.where((todo) => !todo.isCompleted).toList();
        break;
      case TodoFilter.overdue:
        todos = todos.where((todo) => todo.isOverdue).toList();
        break;
      case TodoFilter.all:
      case null:
        break;
    }

    // Aplicar búsqueda
    if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
      final query = state.searchQuery!.toLowerCase();
      todos = todos.where((todo) {
        return todo.title.toLowerCase().contains(query) ||
            (todo.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return todos;
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider para tareas filtradas
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todoListState = ref.watch(todoListProvider);
  final notifier = ref.read(todoListProvider.notifier);
  return notifier.filteredTodos;
});

/// Provider para estadísticas de tareas
final todoStatsProvider = Provider<TodoStats>((ref) {
  final todos = ref.watch(filteredTodosProvider);

  final total = todos.length;
  final completed = todos.where((todo) => todo.isCompleted).length;
  final pending = total - completed;
  final overdue = todos.where((todo) => todo.isOverdue).length;

  return TodoStats(
    total: total,
    completed: completed,
    pending: pending,
    overdue: overdue,
  );
});
