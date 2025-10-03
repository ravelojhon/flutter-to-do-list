import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../database/app_database.dart';
import 'task_repository_impl.dart';

/// Ejemplos de uso del TaskRepository
class TaskRepositoryExample {
  late TaskRepository _repository;
  late AppDatabase _database;

  /// Inicializar el repositorio
  Future<void> initialize() async {
    _database = AppDatabase();
    _repository = TaskRepositoryImpl(_database);
  }

  /// Ejemplo 1: Operaciones CRUD básicas
  Future<void> crudOperations() async {
    print('=== Operaciones CRUD Básicas ===');

    try {
      // 1. Agregar tareas
      print('\n1. Agregando tareas...');
      await _repository.addTask(
        Task(
          id: null,
          title: 'Aprender Flutter',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      );

      await _repository.addTask(
        Task(
          id: null,
          title: 'Implementar Drift',
          isCompleted: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
      );

      await _repository.addTask(
        Task(
          id: null,
          title: 'Escribir tests',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      );

      print('✅ Tareas agregadas exitosamente');

      // 2. Obtener todas las tareas
      print('\n2. Obteniendo todas las tareas...');
      final allTasks = await _repository.getAllTasks();
      print('Total de tareas: ${allTasks.length}');
      for (final task in allTasks) {
        print(
          '  - ${task.title} (${task.isCompleted ? 'Completada' : 'Pendiente'})',
        );
      }

      // 3. Obtener tarea por ID (usar el primer ID disponible)
      if (allTasks.isNotEmpty) {
        final firstTask = allTasks.first;
        print('\n3. Obteniendo tarea por ID: ${firstTask.id}');
        final taskById = await _repository.getTaskById(firstTask.id!);
        if (taskById != null) {
          print('  Tarea encontrada: ${taskById.title}');
        }
      }

      // 4. Actualizar tarea
      if (allTasks.isNotEmpty) {
        final taskToUpdate = allTasks.first;
        print('\n4. Actualizando tarea: ${taskToUpdate.title}');
        final updatedTask = taskToUpdate.copyWith(
          title: '${taskToUpdate.title} - Actualizada',
          isCompleted: true,
          updatedAt: DateTime.now(),
        );
        await _repository.updateTask(updatedTask);
        print('✅ Tarea actualizada');
      }

      // 5. Buscar tareas
      print('\n5. Buscando tareas con "Flutter"...');
      final searchResults = await _repository.searchTasks('Flutter');
      print('Resultados encontrados: ${searchResults.length}');
      for (final task in searchResults) {
        print('  - ${task.title}');
      }

      // 6. Obtener estadísticas
      print('\n6. Estadísticas de tareas...');
      final stats = await _repository.getTaskStats();
      print('  $stats');

      // 7. Eliminar tarea
      if (allTasks.length > 1) {
        final taskToDelete = allTasks[1];
        print('\n7. Eliminando tarea: ${taskToDelete.title}');
        await _repository.deleteTask(taskToDelete.id!);
        print('✅ Tarea eliminada');
      }
    } catch (e) {
      print('❌ Error en operaciones CRUD: $e');
    }
  }

  /// Ejemplo 2: Filtros y búsquedas
  Future<void> filteringAndSearch() async {
    print('\n=== Filtros y Búsquedas ===');

    try {
      // Obtener tareas pendientes
      print('\n1. Tareas pendientes:');
      final pendingTasks = await _repository.getPendingTasks();
      print('Total pendientes: ${pendingTasks.length}');
      for (final task in pendingTasks) {
        print('  - ${task.title}');
      }

      // Obtener tareas completadas
      print('\n2. Tareas completadas:');
      final completedTasks = await _repository.getCompletedTasks();
      print('Total completadas: ${completedTasks.length}');
      for (final task in completedTasks) {
        print('  - ${task.title}');
      }

      // Obtener tareas recientes
      print('\n3. Últimas 3 tareas:');
      final recentTasks = await _repository.getRecentTasks(3);
      for (final task in recentTasks) {
        print('  - ${task.title} (${task.createdAt})');
      }

      // Buscar tareas
      print('\n4. Buscando tareas con "test":');
      final testTasks = await _repository.searchTasks('test');
      print('Resultados: ${testTasks.length}');
      for (final task in testTasks) {
        print('  - ${task.title}');
      }
    } catch (e) {
      print('❌ Error en filtros y búsquedas: $e');
    }
  }

  /// Ejemplo 3: Operaciones avanzadas
  Future<void> advancedOperations() async {
    print('\n=== Operaciones Avanzadas ===');

    try {
      // Obtener todas las tareas para trabajar con ellas
      final allTasks = await _repository.getAllTasks();
      if (allTasks.isEmpty) {
        print('No hay tareas para operaciones avanzadas');
        return;
      }

      // Marcar tarea como completada
      final firstTask = allTasks.first;
      if (firstTask.id != null) {
        print('\n1. Marcando tarea como completada: ${firstTask.title}');
        await _repository.markTaskAsCompleted(firstTask.id!);
        print('✅ Tarea marcada como completada');
      }

      // Actualizar título de tarea
      if (allTasks.length > 1) {
        final secondTask = allTasks[1];
        if (secondTask.id != null) {
          print('\n2. Actualizando título de tarea: ${secondTask.title}');
          await _repository.updateTaskTitle(
            secondTask.id!,
            '${secondTask.title} - Título actualizado',
          );
          print('✅ Título actualizado');
        }
      }

      // Obtener tareas por rango de fechas
      print('\n3. Tareas de los últimos 7 días:');
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentTasks = await _repository.getTasksByDateRange(
        weekAgo,
        DateTime.now(),
      );
      print('Tareas recientes: ${recentTasks.length}');
      for (final task in recentTasks) {
        print('  - ${task.title} (${task.createdAt})');
      }

      // Estadísticas finales
      print('\n4. Estadísticas finales:');
      final finalStats = await _repository.getTaskStats();
      print('  $finalStats');
    } catch (e) {
      print('❌ Error en operaciones avanzadas: $e');
    }
  }

  /// Ejemplo 4: Manejo de errores
  Future<void> errorHandling() async {
    print('\n=== Manejo de Errores ===');

    try {
      // Intentar obtener tarea inexistente
      print('\n1. Intentando obtener tarea inexistente (ID: 99999)...');
      final task = await _repository.getTaskById(99999);
      print('Resultado: ${task ?? 'No encontrada'}');
    } catch (e) {
      print('❌ Error esperado: $e');
    }

    try {
      // Intentar actualizar tarea sin ID
      print('\n2. Intentando actualizar tarea sin ID...');
      final taskWithoutId = Task(
        id: null,
        title: 'Tarea sin ID',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      await _repository.updateTask(taskWithoutId);
    } catch (e) {
      print('❌ Error esperado: $e');
    }

    try {
      // Intentar eliminar tarea inexistente
      print('\n3. Intentando eliminar tarea inexistente (ID: 99999)...');
      await _repository.deleteTask(99999);
    } catch (e) {
      print('❌ Error esperado: $e');
    }

    try {
      // Intentar buscar con query vacío
      print('\n4. Buscando con query vacío...');
      final emptyResults = await _repository.searchTasks('');
      print('Resultados con query vacío: ${emptyResults.length}');
    } catch (e) {
      print('❌ Error inesperado: $e');
    }
  }

  /// Ejemplo 5: Operaciones en lote
  Future<void> batchOperations() async {
    print('\n=== Operaciones en Lote ===');

    try {
      // Agregar múltiples tareas
      print('\n1. Agregando múltiples tareas...');
      final tasksToAdd = [
        Task(
          id: null,
          title: 'Tarea de lote 1',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
        Task(
          id: null,
          title: 'Tarea de lote 2',
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
        Task(
          id: null,
          title: 'Tarea de lote 3',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

      for (final task in tasksToAdd) {
        await _repository.addTask(task);
      }
      print('✅ ${tasksToAdd.length} tareas agregadas');

      // Obtener estadísticas después de agregar
      final stats = await _repository.getTaskStats();
      print('\n2. Estadísticas después de agregar: $stats');

      // Eliminar todas las tareas completadas
      print('\n3. Eliminando tareas completadas...');
      final deletedCount = await _repository.deleteCompletedTasks();
      print('✅ $deletedCount tareas completadas eliminadas');

      // Estadísticas finales
      final finalStats = await _repository.getTaskStats();
      print('\n4. Estadísticas finales: $finalStats');
    } catch (e) {
      print('❌ Error en operaciones en lote: $e');
    }
  }

  /// Ejecutar todos los ejemplos
  Future<void> runAllExamples() async {
    await initialize();

    try {
      await crudOperations();
      await filteringAndSearch();
      await advancedOperations();
      await errorHandling();
      await batchOperations();
    } finally {
      await close();
    }
  }

  /// Cerrar el repositorio
  Future<void> close() async {
    if (_repository is TaskRepositoryImpl) {
      await (_repository as TaskRepositoryImpl).close();
    }
  }
}
