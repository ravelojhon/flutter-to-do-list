import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import '../../core/errors/failures.dart';
import 'get_tasks.dart';
import 'add_task.dart';
import 'update_task.dart';
import 'delete_task.dart';

import 'usecases_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  group('Use Cases Tests', () {
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
    });

    group('GetTasks', () {
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
          mockRepository.getAllTasks(),
        ).thenAnswer((_) async => expectedTasks);

        final getTasks = GetTasks(mockRepository);

        // Act
        final result = await getTasks(NoParams());

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockRepository.getAllTasks()).called(1);
      });

      test(
        'should throw UnexpectedFailure when repository throws exception',
        () async {
          // Arrange
          when(
            mockRepository.getAllTasks(),
          ).thenThrow(Exception('Database error'));

          final getTasks = GetTasks(mockRepository);

          // Act & Assert
          expect(() => getTasks(NoParams()), throwsA(isA<UnexpectedFailure>()));
        },
      );
    });

    group('AddTask', () {
      test('should add task successfully', () async {
        // Arrange
        final params = AddTaskParams(title: 'New Task', isCompleted: false);

        when(
          mockRepository.addTask(any),
        ).thenAnswer((_) async => Future.value());

        final addTask = AddTask(mockRepository);

        // Act
        await addTask(params);

        // Assert
        verify(mockRepository.addTask(any)).called(1);
      });

      test('should throw CacheFailure when title is empty', () async {
        // Arrange
        final params = AddTaskParams(title: '');

        final addTask = AddTask(mockRepository);

        // Act & Assert
        expect(() => addTask(params), throwsA(isA<CacheFailure>()));
      });

      test('should throw CacheFailure when title is too long', () async {
        // Arrange
        final params = AddTaskParams(title: 'A' * 201);

        final addTask = AddTask(mockRepository);

        // Act & Assert
        expect(() => addTask(params), throwsA(isA<CacheFailure>()));
      });

      test('should throw CacheFailure when created date is future', () async {
        // Arrange
        final params = AddTaskParams(
          title: 'New Task',
          createdAt: DateTime.now().add(const Duration(days: 1)),
        );

        final addTask = AddTask(mockRepository);

        // Act & Assert
        expect(() => addTask(params), throwsA(isA<CacheFailure>()));
      });
    });

    group('UpdateTask', () {
      test('should update task successfully', () async {
        // Arrange
        final existingTask = Task(
          id: 1,
          title: 'Original Task',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final params = UpdateTaskParams(
          id: 1,
          title: 'Updated Task',
          isCompleted: true,
        );

        when(
          mockRepository.getTaskById(1),
        ).thenAnswer((_) async => existingTask);
        when(
          mockRepository.updateTask(any),
        ).thenAnswer((_) async => Future.value());

        final updateTask = UpdateTask(mockRepository);

        // Act
        await updateTask(params);

        // Assert
        verify(mockRepository.getTaskById(1)).called(1);
        verify(mockRepository.updateTask(any)).called(1);
      });

      test('should throw CacheFailure when task not found', () async {
        // Arrange
        final params = UpdateTaskParams(id: 1, title: 'Updated Task');

        when(mockRepository.getTaskById(1)).thenAnswer((_) async => null);

        final updateTask = UpdateTask(mockRepository);

        // Act & Assert
        expect(() => updateTask(params), throwsA(isA<CacheFailure>()));
      });

      test('should throw CacheFailure when ID is invalid', () async {
        // Arrange
        final params = UpdateTaskParams(id: 0, title: 'Updated Task');

        final updateTask = UpdateTask(mockRepository);

        // Act & Assert
        expect(() => updateTask(params), throwsA(isA<CacheFailure>()));
      });
    });

    group('DeleteTask', () {
      test('should delete task successfully', () async {
        // Arrange
        final params = DeleteTaskParams(id: 1);

        when(mockRepository.getTaskById(1)).thenAnswer(
          (_) async => Task(
            id: 1,
            title: 'Task to Delete',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        );
        when(
          mockRepository.deleteTask(1),
        ).thenAnswer((_) async => Future.value());

        final deleteTask = DeleteTask(mockRepository);

        // Act
        await deleteTask(params);

        // Assert
        verify(mockRepository.getTaskById(1)).called(1);
        verify(mockRepository.deleteTask(1)).called(1);
      });

      test('should throw CacheFailure when task not found', () async {
        // Arrange
        final params = DeleteTaskParams(id: 1);

        when(mockRepository.getTaskById(1)).thenAnswer((_) async => null);

        final deleteTask = DeleteTask(mockRepository);

        // Act & Assert
        expect(() => deleteTask(params), throwsA(isA<CacheFailure>()));
      });

      test('should throw CacheFailure when ID is invalid', () async {
        // Arrange
        final params = DeleteTaskParams(id: 0);

        final deleteTask = DeleteTask(mockRepository);

        // Act & Assert
        expect(() => deleteTask(params), throwsA(isA<CacheFailure>()));
      });
    });

    group('SearchTasks', () {
      test('should search tasks successfully', () async {
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
          mockRepository.searchTasks(query),
        ).thenAnswer((_) async => expectedTasks);

        final searchTasks = SearchTasks(mockRepository);

        // Act
        final result = await searchTasks(query);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockRepository.searchTasks(query)).called(1);
      });

      test('should throw CacheFailure when query is empty', () async {
        // Arrange
        const query = '';

        final searchTasks = SearchTasks(mockRepository);

        // Act & Assert
        expect(() => searchTasks(query), throwsA(isA<CacheFailure>()));
      });
    });

    group('GetRecentTasks', () {
      test('should get recent tasks successfully', () async {
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
          mockRepository.getRecentTasks(limit),
        ).thenAnswer((_) async => expectedTasks);

        final getRecentTasks = GetRecentTasks(mockRepository);

        // Act
        final result = await getRecentTasks(limit);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockRepository.getRecentTasks(limit)).called(1);
      });

      test('should throw CacheFailure when limit is invalid', () async {
        // Arrange
        const limit = 0;

        final getRecentTasks = GetRecentTasks(mockRepository);

        // Act & Assert
        expect(() => getRecentTasks(limit), throwsA(isA<CacheFailure>()));
      });
    });

    group('AddMultipleTasks', () {
      test('should add multiple tasks successfully', () async {
        // Arrange
        final params = [
          AddTaskParams(title: 'Task 1'),
          AddTaskParams(title: 'Task 2'),
          AddTaskParams(title: 'Task 3'),
        ];

        when(
          mockRepository.addTask(any),
        ).thenAnswer((_) async => Future.value());

        final addMultipleTasks = AddMultipleTasks(mockRepository);

        // Act
        await addMultipleTasks(params);

        // Assert
        verify(mockRepository.addTask(any)).called(params.length);
      });

      test('should throw CacheFailure when params list is empty', () async {
        // Arrange
        final params = <AddTaskParams>[];

        final addMultipleTasks = AddMultipleTasks(mockRepository);

        // Act & Assert
        expect(() => addMultipleTasks(params), throwsA(isA<CacheFailure>()));
      });

      test('should throw CacheFailure when too many tasks', () async {
        // Arrange
        final params = List.generate(
          101,
          (index) => AddTaskParams(title: 'Task $index'),
        );

        final addMultipleTasks = AddMultipleTasks(mockRepository);

        // Act & Assert
        expect(() => addMultipleTasks(params), throwsA(isA<CacheFailure>()));
      });
    });

    group('DeleteMultipleTasks', () {
      test('should delete multiple tasks successfully', () async {
        // Arrange
        final taskIds = [1, 2, 3];
        final tasks = taskIds
            .map(
              (id) => Task(
                id: id,
                title: 'Task $id',
                isCompleted: false,
                createdAt: DateTime.now(),
              ),
            )
            .toList();

        for (final task in tasks) {
          when(
            mockRepository.getTaskById(task.id!),
          ).thenAnswer((_) async => task);
          when(
            mockRepository.deleteTask(task.id!),
          ).thenAnswer((_) async => Future.value());
        }

        final deleteMultipleTasks = DeleteMultipleTasks(mockRepository);

        // Act
        await deleteMultipleTasks(taskIds);

        // Assert
        for (final taskId in taskIds) {
          verify(mockRepository.getTaskById(taskId)).called(1);
          verify(mockRepository.deleteTask(taskId)).called(1);
        }
      });

      test('should throw CacheFailure when taskIds list is empty', () async {
        // Arrange
        final taskIds = <int>[];

        final deleteMultipleTasks = DeleteMultipleTasks(mockRepository);

        // Act & Assert
        expect(
          () => deleteMultipleTasks(taskIds),
          throwsA(isA<CacheFailure>()),
        );
      });

      test('should throw CacheFailure when too many tasks', () async {
        // Arrange
        final taskIds = List.generate(51, (index) => index + 1);

        final deleteMultipleTasks = DeleteMultipleTasks(mockRepository);

        // Act & Assert
        expect(
          () => deleteMultipleTasks(taskIds),
          throwsA(isA<CacheFailure>()),
        );
      });
    });
  });
}
