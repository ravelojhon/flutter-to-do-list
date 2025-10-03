import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../core/errors/exceptions.dart';
import '../models/todo_model.dart';

/// Fuente de datos local para tareas
abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getAllTodos();
  Future<TodoModel?> getTodoById(String id);
  Future<List<TodoModel>> getTodosByStatus(bool isCompleted);
  Future<List<TodoModel>> getTodosByCategory(String category);
  Future<List<TodoModel>> searchTodos(String query);
  Future<TodoModel> createTodo(TodoModel todo);
  Future<TodoModel> updateTodo(TodoModel todo);
  Future<void> deleteTodo(String id);
  Future<TodoModel> completeTodo(String id);
  Future<TodoModel> uncompleteTodo(String id);
  Future<int> deleteCompletedTodos();
  Future<TodoStats> getTodoStats();
}

/// Implementación de la fuente de datos local
class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final AppDatabase database;

  TodoLocalDataSourceImpl({required this.database});

  @override
  Future<List<TodoModel>> getAllTodos() async {
    try {
      final todos = await database.select(database.todos).get();
      return todos.map((todo) => TodoModel.fromMap(todo.toMap())).toList();
    } catch (e) {
      throw CacheException(
        message: 'Error al obtener todas las tareas: $e',
        details: e,
      );
    }
  }

  @override
  Future<TodoModel?> getTodoById(String id) async {
    try {
      final query = database.select(database.todos)
        ..where((tbl) => tbl.id.equals(id));

      final todo = await query.getSingleOrNull();
      return todo != null ? TodoModel.fromMap(todo.toMap()) : null;
    } catch (e) {
      throw CacheException(
        message: 'Error al obtener la tarea por ID: $e',
        details: e,
      );
    }
  }

  @override
  Future<List<TodoModel>> getTodosByStatus(bool isCompleted) async {
    try {
      final query = database.select(database.todos)
        ..where((tbl) => tbl.isCompleted.equals(isCompleted));

      final todos = await query.get();
      return todos.map((todo) => TodoModel.fromMap(todo.toMap())).toList();
    } catch (e) {
      throw CacheException(
        message: 'Error al obtener tareas por estado: $e',
        details: e,
      );
    }
  }

  @override
  Future<List<TodoModel>> getTodosByCategory(String category) async {
    try {
      final query = database.select(database.todos)
        ..where((tbl) => tbl.category.equals(category));

      final todos = await query.get();
      return todos.map((todo) => TodoModel.fromMap(todo.toMap())).toList();
    } catch (e) {
      throw CacheException(
        message: 'Error al obtener tareas por categoría: $e',
        details: e,
      );
    }
  }

  @override
  Future<List<TodoModel>> searchTodos(String query) async {
    try {
      final todosQuery = database.select(database.todos)
        ..where(
          (tbl) => tbl.title.contains(query) | tbl.description.contains(query),
        );

      final todos = await todosQuery.get();
      return todos.map((todo) => TodoModel.fromMap(todo.toMap())).toList();
    } catch (e) {
      throw CacheException(message: 'Error al buscar tareas: $e', details: e);
    }
  }

  @override
  Future<TodoModel> createTodo(TodoModel todo) async {
    try {
      await database
          .into(database.todos)
          .insert(
            TodosCompanion(
              id: Value(todo.id),
              title: Value(todo.title),
              description: Value(todo.description),
              isCompleted: Value(todo.isCompleted),
              createdAt: Value(todo.createdAt),
              updatedAt: Value(todo.updatedAt),
              dueDate: Value(todo.dueDate),
              priority: Value(todo.priority),
              category: Value(todo.category),
              tags: Value(todo.tags?.join(',')),
            ),
          );
      return todo;
    } catch (e) {
      throw CacheException(message: 'Error al crear la tarea: $e', details: e);
    }
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    try {
      await database
          .update(database.todos)
          .replace(
            TodosCompanion(
              id: Value(todo.id),
              title: Value(todo.title),
              description: Value(todo.description),
              isCompleted: Value(todo.isCompleted),
              createdAt: Value(todo.createdAt),
              updatedAt: Value(DateTime.now()),
              dueDate: Value(todo.dueDate),
              priority: Value(todo.priority),
              category: Value(todo.category),
              tags: Value(todo.tags?.join(',')),
            ),
          );
      return todo.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw CacheException(
        message: 'Error al actualizar la tarea: $e',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await (database.delete(
        database.todos,
      )..where((tbl) => tbl.id.equals(id))).go();
    } catch (e) {
      throw CacheException(
        message: 'Error al eliminar la tarea: $e',
        details: e,
      );
    }
  }

  @override
  Future<TodoModel> completeTodo(String id) async {
    try {
      final todo = await getTodoById(id);
      if (todo == null) {
        throw CacheException(message: 'Tarea no encontrada');
      }

      final updatedTodo = todo.copyWith(
        isCompleted: true,
        updatedAt: DateTime.now(),
      );

      await updateTodo(updatedTodo);
      return updatedTodo;
    } catch (e) {
      throw CacheException(
        message: 'Error al completar la tarea: $e',
        details: e,
      );
    }
  }

  @override
  Future<TodoModel> uncompleteTodo(String id) async {
    try {
      final todo = await getTodoById(id);
      if (todo == null) {
        throw CacheException(message: 'Tarea no encontrada');
      }

      final updatedTodo = todo.copyWith(
        isCompleted: false,
        updatedAt: DateTime.now(),
      );

      await updateTodo(updatedTodo);
      return updatedTodo;
    } catch (e) {
      throw CacheException(
        message: 'Error al marcar tarea como pendiente: $e',
        details: e,
      );
    }
  }

  @override
  Future<int> deleteCompletedTodos() async {
    try {
      return await (database.delete(
        database.todos,
      )..where((tbl) => tbl.isCompleted.equals(true))).go();
    } catch (e) {
      throw CacheException(
        message: 'Error al eliminar tareas completadas: $e',
        details: e,
      );
    }
  }

  @override
  Future<TodoStats> getTodoStats() async {
    try {
      final allTodos = await getAllTodos();
      final total = allTodos.length;
      final completed = allTodos.where((todo) => todo.isCompleted).length;
      final pending = total - completed;
      final overdue = allTodos
          .where(
            (todo) =>
                todo.dueDate != null &&
                !todo.isCompleted &&
                DateTime.now().isAfter(todo.dueDate!),
          )
          .length;

      return TodoStats(
        total: total,
        completed: completed,
        pending: pending,
        overdue: overdue,
      );
    } catch (e) {
      throw CacheException(
        message: 'Error al obtener estadísticas: $e',
        details: e,
      );
    }
  }
}

/// Estadísticas de tareas para la capa de datos
class TodoStats {
  final int total;
  final int completed;
  final int pending;
  final int overdue;

  const TodoStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
  });
}
