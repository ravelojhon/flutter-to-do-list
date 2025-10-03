import 'app_database.dart';

/// Ejemplo de uso del AppDatabase y TasksDao
class DatabaseExample {
  late AppDatabase _database;

  /// Inicializar la base de datos
  Future<void> initialize() async {
    _database = AppDatabase();
  }

  /// Ejemplo de operaciones CRUD
  Future<void> crudExample() async {
    final dao = _database.tasksDao;

    // 1. Insertar tareas
    print('=== Insertando tareas ===');
    final task1Id = await dao.insertTaskData(
      title: 'Aprender Flutter',
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    print('Tarea insertada con ID: $task1Id');

    final task2Id = await dao.insertTaskData(
      title: 'Implementar Drift',
      isCompleted: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    );
    print('Tarea insertada con ID: $task2Id');

    // 2. Obtener todas las tareas
    print('\n=== Todas las tareas ===');
    final allTasks = await dao.getAllTasks();
    for (final task in allTasks) {
      print(
        'ID: ${task.id}, Título: ${task.title}, Completada: ${task.isCompleted}',
      );
    }

    // 3. Obtener tareas pendientes
    print('\n=== Tareas pendientes ===');
    final pendingTasks = await dao.getTasksByStatus(false);
    for (final task in pendingTasks) {
      print('Título: ${task.title}');
    }

    // 4. Actualizar tarea
    print('\n=== Actualizando tarea ===');
    final updated = await dao.updateTaskById(
      task1Id,
      title: 'Aprender Flutter y Dart',
      isCompleted: true,
      updatedAt: DateTime.now(),
    );
    print('Tarea actualizada: $updated');

    // 5. Buscar tareas
    print('\n=== Buscando tareas ===');
    final searchResults = await dao.searchTasks('Flutter');
    for (final task in searchResults) {
      print('Encontrada: ${task.title}');
    }

    // 6. Obtener estadísticas
    print('\n=== Estadísticas ===');
    final stats = await dao.getTaskStats();
    print('Total: ${stats.total}');
    print('Completadas: ${stats.completed}');
    print('Pendientes: ${stats.pending}');
    print(
      'Porcentaje completado: ${stats.completionPercentage.toStringAsFixed(1)}%',
    );

    // 7. Eliminar tarea
    print('\n=== Eliminando tarea ===');
    final deleted = await dao.deleteTask(task2Id);
    print('Tarea eliminada: $deleted');

    // 8. Mostrar tareas finales
    print('\n=== Tareas finales ===');
    final finalTasks = await dao.getAllTasks();
    for (final task in finalTasks) {
      print(
        'ID: ${task.id}, Título: ${task.title}, Completada: ${task.isCompleted}',
      );
    }
  }

  /// Cerrar la base de datos
  Future<void> close() async {
    await _database.close();
  }
}
