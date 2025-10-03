import 'package:flutter_test/flutter_test.dart';
import 'task_model.dart';
import '../../domain/entities/task.dart';

void main() {
  group('TaskModel Tests', () {
    test('should create TaskModel from entity', () {
      // Crear entidad Task
      final task = Task(
        id: 1,
        title: 'Test Task',
        isCompleted: false,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      // Convertir a TaskModel
      final taskModel = TaskModel.fromEntity(task);

      expect(taskModel.id, equals(1));
      expect(taskModel.title, equals('Test Task'));
      expect(taskModel.isCompleted, equals(false));
      expect(
        taskModel.createdAt,
        equals(DateTime(2024, 1, 1).millisecondsSinceEpoch),
      );
      expect(
        taskModel.updatedAt,
        equals(DateTime(2024, 1, 2).millisecondsSinceEpoch),
      );
    });

    test('should create entity from TaskModel', () {
      // Crear TaskModel
      final taskModel = TaskModel(
        id: 2,
        title: 'Model Task',
        isCompleted: true,
        createdAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAt: DateTime(2024, 1, 2).millisecondsSinceEpoch,
      );

      // Convertir a entidad Task
      final task = taskModel.toEntity();

      expect(task.id, equals(2));
      expect(task.title, equals('Model Task'));
      expect(task.isCompleted, equals(true));
      expect(task.createdAt, equals(DateTime(2024, 1, 1)));
      expect(task.updatedAt, equals(DateTime(2024, 1, 2)));
    });

    test('should handle null ID correctly', () {
      // Entidad sin ID
      final task = Task(
        id: null,
        title: 'No ID Task',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Convertir a TaskModel
      final taskModel = TaskModel.fromEntity(task);
      expect(taskModel.id, equals(0));

      // Convertir de vuelta a entidad
      final convertedTask = taskModel.toEntity();
      expect(convertedTask.id, isNull);
    });

    test('should handle null updatedAt correctly', () {
      // Entidad sin updatedAt
      final task = Task(
        id: 1,
        title: 'No Update Task',
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      // Convertir a TaskModel
      final taskModel = TaskModel.fromEntity(task);
      expect(taskModel.updatedAt, isNull);
      expect(taskModel.isUpdated, isFalse);

      // Convertir de vuelta a entidad
      final convertedTask = taskModel.toEntity();
      expect(convertedTask.updatedAt, isNull);
    });

    test('should create TasksCompanion correctly', () {
      final taskModel = TaskModel(
        id: 0, // ID 0 para insertar
        title: 'New Task',
        isCompleted: false,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: null,
      );

      final companion = taskModel.toCompanion();

      expect(companion.id, isA<Value<int>>());
      expect(companion.title.value, equals('New Task'));
      expect(companion.isCompleted.value, equals(false));
    });

    test('should copy with modifications', () {
      final original = TaskModel(
        id: 1,
        title: 'Original',
        isCompleted: false,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: null,
      );

      final updated = original.copyWith(
        title: 'Updated',
        isCompleted: true,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      expect(updated.id, equals(1));
      expect(updated.title, equals('Updated'));
      expect(updated.isCompleted, equals(true));
      expect(updated.updatedAt, isNotNull);
      expect(updated.isUpdated, isTrue);
    });

    test('should serialize and deserialize correctly', () {
      final original = TaskModel(
        id: 3,
        title: 'Serializable Task',
        isCompleted: true,
        createdAt: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        updatedAt: DateTime(2024, 1, 2).millisecondsSinceEpoch,
      );

      // Convertir a Map
      final map = original.toMap();
      expect(map['id'], equals(3));
      expect(map['title'], equals('Serializable Task'));
      expect(map['isCompleted'], equals(true));

      // Recrear desde Map
      final recreated = TaskModel.fromMap(map);
      expect(recreated, equals(original));
    });

    test('should calculate completion percentage correctly', () {
      final stats = TaskStats(total: 10, completed: 7, pending: 3);

      expect(stats.completionPercentage, equals(70.0));

      final emptyStats = TaskStats(total: 0, completed: 0, pending: 0);

      expect(emptyStats.completionPercentage, equals(0.0));
    });

    test('should handle equality correctly', () {
      final task1 = TaskModel(
        id: 1,
        title: 'Same Task',
        isCompleted: false,
        createdAt: 1000,
        updatedAt: null,
      );

      final task2 = TaskModel(
        id: 1,
        title: 'Same Task',
        isCompleted: false,
        createdAt: 1000,
        updatedAt: null,
      );

      final task3 = TaskModel(
        id: 2,
        title: 'Different Task',
        isCompleted: false,
        createdAt: 1000,
        updatedAt: null,
      );

      expect(task1, equals(task2));
      expect(task1, isNot(equals(task3)));
      expect(task1.hashCode, equals(task2.hashCode));
    });

    test('should convert round trip correctly', () {
      final originalTask = Task(
        id: 5,
        title: 'Round Trip Task',
        isCompleted: true,
        createdAt: DateTime(2024, 2, 1),
        updatedAt: DateTime(2024, 2, 2),
      );

      // Task -> TaskModel -> Task
      final taskModel = TaskModel.fromEntity(originalTask);
      final convertedTask = taskModel.toEntity();

      expect(convertedTask.id, equals(originalTask.id));
      expect(convertedTask.title, equals(originalTask.title));
      expect(convertedTask.isCompleted, equals(originalTask.isCompleted));
      expect(convertedTask.createdAt, equals(originalTask.createdAt));
      expect(convertedTask.updatedAt, equals(originalTask.updatedAt));
    });
  });
}
