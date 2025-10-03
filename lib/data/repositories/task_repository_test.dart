import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../database/app_database.dart';
import '../database/tasks_dao_enhanced.dart';
import 'task_repository_impl.dart';

import 'task_repository_test.mocks.dart';

@GenerateMocks([AppDatabase, TasksDaoEnhanced])
void main() {
  group('TaskRepositoryImpl Tests', () {
    late TaskRepositoryImpl repository;
    late MockAppDatabase mockDatabase;
    late MockTasksDaoEnhanced mockDao;

    setUp(() {
      mockDatabase = MockAppDatabase();
      mockDao = MockTasksDaoEnhanced(mockDatabase);
      repository = TaskRepositoryImpl(mockDatabase);
    });

    group('getAllTasks', () {
      test('should return all tasks successfully', () async {
        // Arrange
        final expectedTasks = [
          Task(
            id: 1,
            title: 'Test Task 1',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          Task(
            id: 2,
            title: 'Test Task 2',
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
        ];

        when(
          mockDao.getAllTasksAsEntities(),
        ).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockDao.getAllTasksAsEntities()).called(1);
      });

      test('should throw failure when exception occurs', () async {
        // Arrange
        when(
          mockDao.getAllTasksAsEntities(),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.getAllTasks(),
          throwsA(isA<UnexpectedFailure>()),
        );
      });
    });

    group('addTask', () {
      test('should add task successfully', () async {
        // Arrange
        final task = Task(
          id: null,
          title: 'New Task',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        when(
          mockDao.insertTaskEntity(any),
        ).thenAnswer((_) async => Future.value());

        // Act
        await repository.addTask(task);

        // Assert
        verify(mockDao.insertTaskEntity(task)).called(1);
      });

      test('should throw failure when exception occurs', () async {
        // Arrange
        final task = Task(
          id: null,
          title: 'New Task',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        when(
          mockDao.insertTaskEntity(any),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.addTask(task),
          throwsA(isA<UnexpectedFailure>()),
        );
      });
    });

    group('updateTask', () {
      test('should update task successfully', () async {
        // Arrange
        final task = Task(
          id: 1,
          title: 'Updated Task',
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockDao.updateTaskEntity(any)).thenAnswer((_) async => true);

        // Act
        await repository.updateTask(task);

        // Assert
        verify(mockDao.updateTaskEntity(task)).called(1);
      });

      test('should throw failure when task has no ID', () async {
        // Arrange
        final task = Task(
          id: null,
          title: 'Task without ID',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(() => repository.updateTask(task), throwsA(isA<CacheFailure>()));
      });

      test('should throw failure when task not found', () async {
        // Arrange
        final task = Task(
          id: 1,
          title: 'Task to update',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        when(mockDao.updateTaskEntity(any)).thenAnswer((_) async => false);

        // Act & Assert
        expect(() => repository.updateTask(task), throwsA(isA<CacheFailure>()));
      });
    });

    group('deleteTask', () {
      test('should delete task successfully', () async {
        // Arrange
        const taskId = 1;

        when(mockDao.deleteTask(any)).thenAnswer((_) async => true);

        // Act
        await repository.deleteTask(taskId);

        // Assert
        verify(mockDao.deleteTask(taskId)).called(1);
      });

      test('should throw failure when task not found', () async {
        // Arrange
        const taskId = 999;

        when(mockDao.deleteTask(any)).thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => repository.deleteTask(taskId),
          throwsA(isA<CacheFailure>()),
        );
      });
    });

    group('getTaskById', () {
      test('should return task when found', () async {
        // Arrange
        const taskId = 1;
        final expectedTask = Task(
          id: taskId,
          title: 'Found Task',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        when(
          mockDao.getTaskEntityById(any),
        ).thenAnswer((_) async => expectedTask);

        // Act
        final result = await repository.getTaskById(taskId);

        // Assert
        expect(result, equals(expectedTask));
        verify(mockDao.getTaskEntityById(taskId)).called(1);
      });

      test('should return null when task not found', () async {
        // Arrange
        const taskId = 999;

        when(mockDao.getTaskEntityById(any)).thenAnswer((_) async => null);

        // Act
        final result = await repository.getTaskById(taskId);

        // Assert
        expect(result, isNull);
        verify(mockDao.getTaskEntityById(taskId)).called(1);
      });
    });

    group('getTasksByStatus', () {
      test('should return tasks by status', () async {
        // Arrange
        final expectedTasks = [
          Task(
            id: 1,
            title: 'Pending Task',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ];

        when(
          mockDao.getTasksByStatusAsEntities(any),
        ).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getTasksByStatus(false);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockDao.getTasksByStatusAsEntities(false)).called(1);
      });
    });

    group('searchTasks', () {
      test('should return search results', () async {
        // Arrange
        const query = 'test';
        final expectedTasks = [
          Task(
            id: 1,
            title: 'Test Task',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ];

        when(
          mockDao.searchTasksAsEntities(any),
        ).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.searchTasks(query);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockDao.searchTasksAsEntities(query)).called(1);
      });

      test('should return all tasks when query is empty', () async {
        // Arrange
        const query = '';
        final expectedTasks = [
          Task(
            id: 1,
            title: 'Task 1',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          Task(
            id: 2,
            title: 'Task 2',
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
        ];

        when(
          mockDao.getAllTasksAsEntities(),
        ).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.searchTasks(query);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockDao.getAllTasksAsEntities()).called(1);
        verifyNever(mockDao.searchTasksAsEntities(any));
      });
    });

    group('getRecentTasks', () {
      test('should return recent tasks', () async {
        // Arrange
        const limit = 5;
        final expectedTasks = [
          Task(
            id: 1,
            title: 'Recent Task',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ];

        when(
          mockDao.getRecentTasksAsEntities(any),
        ).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getRecentTasks(limit);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockDao.getRecentTasksAsEntities(limit)).called(1);
      });

      test('should throw failure when limit is invalid', () async {
        // Act & Assert
        expect(
          () => repository.getRecentTasks(0),
          throwsA(isA<CacheFailure>()),
        );
        expect(
          () => repository.getRecentTasks(-1),
          throwsA(isA<CacheFailure>()),
        );
      });
    });

    group('getTaskStats', () {
      test('should return task statistics', () async {
        // Arrange
        const expectedStats = TaskStats(total: 10, completed: 7, pending: 3);

        when(
          mockDao.getTaskStatsFromModels(),
        ).thenAnswer((_) async => expectedStats);

        // Act
        final result = await repository.getTaskStats();

        // Assert
        expect(result, equals(expectedStats));
        verify(mockDao.getTaskStatsFromModels()).called(1);
      });
    });

    group('updateTaskTitle', () {
      test('should update task title successfully', () async {
        // Arrange
        const taskId = 1;
        const newTitle = 'New Title';

        when(mockDao.updateTaskTitle(any, any)).thenAnswer((_) async => true);

        // Act
        await repository.updateTaskTitle(taskId, newTitle);

        // Assert
        verify(mockDao.updateTaskTitle(taskId, newTitle)).called(1);
      });

      test('should throw failure when title is empty', () async {
        // Act & Assert
        expect(
          () => repository.updateTaskTitle(1, ''),
          throwsA(isA<CacheFailure>()),
        );
        expect(
          () => repository.updateTaskTitle(1, '   '),
          throwsA(isA<CacheFailure>()),
        );
      });
    });

    group('getTasksByDateRange', () {
      test('should return tasks in date range', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        final expectedTasks = [
          Task(
            id: 1,
            title: 'Task in range',
            isCompleted: false,
            createdAt: DateTime(2024, 1, 15),
          ),
        ];

        when(
          mockDao.getTasksByDateRangeAsEntities(any, any),
        ).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getTasksByDateRange(startDate, endDate);

        // Assert
        expect(result, equals(expectedTasks));
        verify(
          mockDao.getTasksByDateRangeAsEntities(startDate, endDate),
        ).called(1);
      });

      test('should throw failure when start date is after end date', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 31);
        final endDate = DateTime(2024, 1, 1);

        // Act & Assert
        expect(
          () => repository.getTasksByDateRange(startDate, endDate),
          throwsA(isA<CacheFailure>()),
        );
      });
    });
  });
}
