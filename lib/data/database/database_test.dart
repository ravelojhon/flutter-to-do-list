import 'package:flutter_test/flutter_test.dart';
import 'app_database.dart';

void main() {
  group('AppDatabase Tests', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase();
    });

    tearDown(() async {
      await database.close();
    });

    test('should create database and tables', () async {
      // Verificar que la base de datos se crea correctamente
      expect(database, isNotNull);
      expect(database.tasksDao, isNotNull);
    });

    test('should insert and retrieve tasks', () async {
      final dao = database.tasksDao;

      // Insertar tarea
      final taskId = await dao.insertTaskData(
        title: 'Test Task',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      expect(taskId, greaterThan(0));

      // Obtener tarea por ID
      final task = await dao.getTaskById(taskId);
      expect(task, isNotNull);
      expect(task!.title, equals('Test Task'));
      expect(task.isCompleted, equals(false));
    });

    test('should update task', () async {
      final dao = database.tasksDao;

      // Insertar tarea
      final taskId = await dao.insertTaskData(
        title: 'Original Title',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Actualizar tarea
      final updated = await dao.updateTaskById(
        taskId,
        title: 'Updated Title',
        isCompleted: true,
        updatedAt: DateTime.now(),
      );

      expect(updated, isTrue);

      // Verificar actualización
      final task = await dao.getTaskById(taskId);
      expect(task!.title, equals('Updated Title'));
      expect(task.isCompleted, equals(true));
    });

    test('should delete task', () async {
      final dao = database.tasksDao;

      // Insertar tarea
      final taskId = await dao.insertTaskData(
        title: 'Task to Delete',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Eliminar tarea
      final deleted = await dao.deleteTask(taskId);
      expect(deleted, isTrue);

      // Verificar eliminación
      final task = await dao.getTaskById(taskId);
      expect(task, isNull);
    });

    test('should get task statistics', () async {
      final dao = database.tasksDao;

      // Insertar tareas de prueba
      await dao.insertTaskData(
        title: 'Task 1',
        isCompleted: true,
        createdAt: DateTime.now(),
      );
      await dao.insertTaskData(
        title: 'Task 2',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      await dao.insertTaskData(
        title: 'Task 3',
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      // Obtener estadísticas
      final stats = await dao.getTaskStats();
      expect(stats.total, equals(3));
      expect(stats.completed, equals(2));
      expect(stats.pending, equals(1));
      expect(stats.completionPercentage, equals(66.7));
    });

    test('should search tasks', () async {
      final dao = database.tasksDao;

      // Insertar tareas de prueba
      await dao.insertTaskData(
        title: 'Flutter Development',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      await dao.insertTaskData(
        title: 'Dart Learning',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      await dao.insertTaskData(
        title: 'React Native',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Buscar tareas
      final flutterTasks = await dao.searchTasks('Flutter');
      expect(flutterTasks.length, equals(1));
      expect(flutterTasks.first.title, equals('Flutter Development'));

      final dartTasks = await dao.searchTasks('Dart');
      expect(dartTasks.length, equals(1));
      expect(dartTasks.first.title, equals('Dart Learning'));
    });
  });
}
