import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../core/errors/failures.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/task_repository_impl.dart';
import 'get_tasks.dart';
import 'add_task.dart';
import 'update_task.dart';
import 'delete_task.dart';

/// Ejemplos de uso de todos los Use Cases
class UseCasesExample {
  late TaskRepository _repository;
  late AppDatabase _database;

  /// Inicializar el repositorio
  Future<void> initialize() async {
    _database = AppDatabase();
    _repository = TaskRepositoryImpl(_database);
  }

  /// Ejemplo 1: Use Cases de GetTasks
  Future<void> getTasksExamples() async {
    print('=== Use Cases de GetTasks ===');

    try {
      // GetTasks - Obtener todas las tareas
      final getTasks = GetTasks(_repository);
      final allTasks = await getTasks(NoParams());
      print('1. Todas las tareas: ${allTasks.length}');

      // GetTasksByStatus - Obtener por estado
      final getTasksByStatus = GetTasksByStatus(_repository);
      final pendingTasks = await getTasksByStatus(false);
      final completedTasks = await getTasksByStatus(true);
      print('2. Tareas pendientes: ${pendingTasks.length}');
      print('3. Tareas completadas: ${completedTasks.length}');

      // GetPendingTasks - Obtener pendientes
      final getPendingTasks = GetPendingTasks(_repository);
      final pending = await getPendingTasks(NoParams());
      print('4. Tareas pendientes (método específico): ${pending.length}');

      // GetCompletedTasks - Obtener completadas
      final getCompletedTasks = GetCompletedTasks(_repository);
      final completed = await getCompletedTasks(NoParams());
      print('5. Tareas completadas (método específico): ${completed.length}');

      // SearchTasks - Buscar tareas
      final searchTasks = SearchTasks(_repository);
      final searchResults = await searchTasks('Flutter');
      print('6. Resultados de búsqueda "Flutter": ${searchResults.length}');

      // GetRecentTasks - Obtener recientes
      final getRecentTasks = GetRecentTasks(_repository);
      final recent = await getRecentTasks(5);
      print('7. Últimas 5 tareas: ${recent.length}');

      // GetTaskStats - Obtener estadísticas
      final getTaskStats = GetTaskStats(_repository);
      final stats = await getTaskStats(NoParams());
      print('8. Estadísticas: $stats');
    } catch (e) {
      print('❌ Error en GetTasks: $e');
    }
  }

  /// Ejemplo 2: Use Cases de AddTask
  Future<void> addTaskExamples() async {
    print('\n=== Use Cases de AddTask ===');

    try {
      // AddTask - Agregar tarea básica
      final addTask = AddTask(_repository);
      final addTaskParams = AddTaskParams(
        title: 'Nueva tarea desde UseCase',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      await addTask(addTaskParams);
      print('1. ✅ Tarea agregada exitosamente');

      // AddTaskWithValidation - Agregar con validaciones
      final addTaskWithValidation = AddTaskWithValidation(_repository);
      final validatedParams = AddTaskParams(
        title: 'Tarea con validación',
        isCompleted: false,
      );
      await addTaskWithValidation(validatedParams);
      print('2. ✅ Tarea con validación agregada');

      // AddMultipleTasks - Agregar múltiples tareas
      final addMultipleTasks = AddMultipleTasks(_repository);
      final multipleParams = [
        AddTaskParams(title: 'Tarea múltiple 1'),
        AddTaskParams(title: 'Tarea múltiple 2', isCompleted: true),
        AddTaskParams(title: 'Tarea múltiple 3'),
      ];
      await addMultipleTasks(multipleParams);
      print('3. ✅ ${multipleParams.length} tareas múltiples agregadas');

      // Intentar agregar tarea con título vacío (debe fallar)
      try {
        final invalidParams = AddTaskParams(title: '');
        await addTask(invalidParams);
      } catch (e) {
        print('4. ❌ Error esperado con título vacío: $e');
      }

      // Intentar agregar tarea con título muy largo (debe fallar)
      try {
        final longTitle = 'A' * 201; // Más de 200 caracteres
        final invalidParams = AddTaskParams(title: longTitle);
        await addTask(invalidParams);
      } catch (e) {
        print('5. ❌ Error esperado con título muy largo: $e');
      }
    } catch (e) {
      print('❌ Error en AddTask: $e');
    }
  }

  /// Ejemplo 3: Use Cases de UpdateTask
  Future<void> updateTaskExamples() async {
    print('\n=== Use Cases de UpdateTask ===');

    try {
      // Obtener una tarea para actualizar
      final getTasks = GetTasks(_repository);
      final tasks = await getTasks(NoParams());
      if (tasks.isEmpty) {
        print('No hay tareas para actualizar');
        return;
      }

      final taskToUpdate = tasks.first;
      print('1. Tarea a actualizar: ${taskToUpdate.title}');

      // UpdateTask - Actualizar tarea completa
      final updateTask = UpdateTask(_repository);
      final updateParams = UpdateTaskParams(
        id: taskToUpdate.id!,
        title: '${taskToUpdate.title} - Actualizada',
        isCompleted: true,
        updatedAt: DateTime.now(),
      );
      await updateTask(updateParams);
      print('2. ✅ Tarea actualizada completamente');

      // UpdateTaskTitle - Actualizar solo título
      final updateTaskTitle = UpdateTaskTitle(_repository);
      final titleParams = UpdateTaskParams.updateTitle(
        taskToUpdate.id!,
        'Solo título actualizado',
      );
      await updateTaskTitle(titleParams);
      print('3. ✅ Solo título actualizado');

      // MarkTaskAsCompleted - Marcar como completada
      final markAsCompleted = MarkTaskAsCompleted(_repository);
      await markAsCompleted(taskToUpdate.id!);
      print('4. ✅ Tarea marcada como completada');

      // MarkTaskAsPending - Marcar como pendiente
      final markAsPending = MarkTaskAsPending(_repository);
      await markAsPending(taskToUpdate.id!);
      print('5. ✅ Tarea marcada como pendiente');

      // UpdateMultipleTasks - Actualizar múltiples tareas
      if (tasks.length > 1) {
        final updateMultipleTasks = UpdateMultipleTasks(_repository);
        final multipleUpdateParams = tasks.take(2).map((task) {
          return UpdateTaskParams(
            id: task.id!,
            title: '${task.title} - Actualizada múltiple',
            updatedAt: DateTime.now(),
          );
        }).toList();
        await updateMultipleTasks(multipleUpdateParams);
        print(
          '6. ✅ ${multipleUpdateParams.length} tareas actualizadas múltiples',
        );
      }

      // Intentar actualizar tarea inexistente (debe fallar)
      try {
        final invalidParams = UpdateTaskParams(
          id: 99999,
          title: 'Tarea inexistente',
        );
        await updateTask(invalidParams);
      } catch (e) {
        print('7. ❌ Error esperado con tarea inexistente: $e');
      }
    } catch (e) {
      print('❌ Error en UpdateTask: $e');
    }
  }

  /// Ejemplo 4: Use Cases de DeleteTask
  Future<void> deleteTaskExamples() async {
    print('\n=== Use Cases de DeleteTask ===');

    try {
      // Obtener tareas para eliminar
      final getTasks = GetTasks(_repository);
      final tasks = await getTasks(NoParams());
      if (tasks.isEmpty) {
        print('No hay tareas para eliminar');
        return;
      }

      // DeleteTaskById - Eliminar por ID
      final deleteTaskById = DeleteTaskById(_repository);
      final taskToDelete = tasks.first;
      await deleteTaskById(taskToDelete.id!);
      print('1. ✅ Tarea eliminada por ID: ${taskToDelete.title}');

      // DeleteTask - Eliminar con parámetros
      if (tasks.length > 1) {
        final deleteTask = DeleteTask(_repository);
        final deleteParams = DeleteTaskParams(id: tasks[1].id!, force: false);
        await deleteTask(deleteParams);
        print('2. ✅ Tarea eliminada con parámetros: ${tasks[1].title}');
      }

      // DeleteMultipleTasks - Eliminar múltiples tareas
      if (tasks.length > 2) {
        final deleteMultipleTasks = DeleteMultipleTasks(_repository);
        final taskIdsToDelete = tasks
            .skip(2)
            .take(2)
            .map((task) => task.id!)
            .toList();
        await deleteMultipleTasks(taskIdsToDelete);
        print('3. ✅ ${taskIdsToDelete.length} tareas múltiples eliminadas');
      }

      // DeleteCompletedTasks - Eliminar tareas completadas
      final deleteCompletedTasks = DeleteCompletedTasks(_repository);
      final deletedCount = await deleteCompletedTasks(NoParams());
      print('4. ✅ $deletedCount tareas completadas eliminadas');

      // DeleteTasksByDateRange - Eliminar por rango de fechas
      final deleteTasksByDateRange = DeleteTasksByDateRange(_repository);
      final dateRangeParams = DateRangeParams(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );
      final deletedByDate = await deleteTasksByDateRange(dateRangeParams);
      print('5. ✅ $deletedByDate tareas eliminadas por rango de fechas');

      // DeleteTaskWithConfirmation - Eliminar con confirmación
      if (tasks.isNotEmpty) {
        final deleteTaskWithConfirmation = DeleteTaskWithConfirmation(
          _repository,
        );
        final confirmParams = DeleteTaskParams(
          id: tasks.first.id!,
          force: false,
        );
        await deleteTaskWithConfirmation(confirmParams);
        print('6. ✅ Tarea eliminada con confirmación');
      }

      // Intentar eliminar tarea inexistente (debe fallar)
      try {
        await deleteTaskById(99999);
      } catch (e) {
        print('7. ❌ Error esperado con tarea inexistente: $e');
      }
    } catch (e) {
      print('❌ Error en DeleteTask: $e');
    }
  }

  /// Ejemplo 5: Flujo completo con múltiples Use Cases
  Future<void> completeWorkflowExample() async {
    print('\n=== Flujo Completo con Use Cases ===');

    try {
      // 1. Agregar tareas iniciales
      print('\n1. Agregando tareas iniciales...');
      final addTask = AddTask(_repository);
      final initialTasks = [
        AddTaskParams(title: 'Tarea de flujo 1', isCompleted: false),
        AddTaskParams(title: 'Tarea de flujo 2', isCompleted: true),
        AddTaskParams(title: 'Tarea de flujo 3', isCompleted: false),
      ];

      for (final taskParams in initialTasks) {
        await addTask(taskParams);
      }
      print('✅ ${initialTasks.length} tareas iniciales agregadas');

      // 2. Obtener estadísticas iniciales
      final getTaskStats = GetTaskStats(_repository);
      final initialStats = await getTaskStats(NoParams());
      print('\n2. Estadísticas iniciales: $initialStats');

      // 3. Buscar y actualizar tareas
      print('\n3. Buscando y actualizando tareas...');
      final searchTasks = SearchTasks(_repository);
      final searchResults = await searchTasks('flujo');
      print('   Tareas encontradas: ${searchResults.length}');

      if (searchResults.isNotEmpty) {
        final updateTask = UpdateTask(_repository);
        final taskToUpdate = searchResults.first;
        final updateParams = UpdateTaskParams(
          id: taskToUpdate.id!,
          title: '${taskToUpdate.title} - Procesada',
          isCompleted: true,
          updatedAt: DateTime.now(),
        );
        await updateTask(updateParams);
        print('   ✅ Tarea actualizada: ${taskToUpdate.title}');
      }

      // 4. Obtener estadísticas finales
      final finalStats = await getTaskStats(NoParams());
      print('\n4. Estadísticas finales: $finalStats');

      // 5. Limpiar tareas de prueba
      print('\n5. Limpiando tareas de prueba...');
      final deleteCompletedTasks = DeleteCompletedTasks(_repository);
      final deletedCount = await deleteCompletedTasks(NoParams());
      print('   ✅ $deletedCount tareas completadas eliminadas');

      // 6. Estadísticas finales después de limpieza
      final cleanedStats = await getTaskStats(NoParams());
      print('\n6. Estadísticas después de limpieza: $cleanedStats');
    } catch (e) {
      print('❌ Error en flujo completo: $e');
    }
  }

  /// Ejecutar todos los ejemplos
  Future<void> runAllExamples() async {
    await initialize();

    try {
      await getTasksExamples();
      await addTaskExamples();
      await updateTaskExamples();
      await deleteTaskExamples();
      await completeWorkflowExample();
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
