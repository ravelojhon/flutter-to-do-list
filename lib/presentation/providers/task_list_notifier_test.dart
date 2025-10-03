import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../core/errors/failures.dart';
import 'task_list_notifier.dart';

import 'task_list_notifier_test.mocks.dart';

@GenerateMocks([GetTasks, AddTask, UpdateTask, DeleteTask])
void main() {
  group('TaskListNotifier Tests', () {
    late MockGetTasks mockGetTasks;
    late MockAddTask mockAddTask;
    late MockUpdateTask mockUpdateTask;
    late MockDeleteTask mockDeleteTask;
    late TaskListNotifier notifier;

    setUp(() {
      mockGetTasks = MockGetTasks();
      mockAddTask = MockAddTask();
      mockUpdateTask = MockUpdateTask();
      mockDeleteTask = MockDeleteTask();

      notifier = TaskListNotifier(
        getTasks: mockGetTasks,
        addTask: mockAddTask,
        updateTask: mockUpdateTask,
        deleteTask: mockDeleteTask,
      );
    });

    group('Initial State', () {
      test('should have initial state with empty tasks', () {
        expect(notifier.state.isLoading, false);
        expect(notifier.state.tasks, isEmpty);
        expect(notifier.state.error, isNull);
      });
    });

    group('loadTasks', () {
      test('should load tasks successfully', () async {
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

        when(mockGetTasks(any)).thenAnswer((_) async => expectedTasks);

        // Act
        await notifier.loadTasks();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.tasks, equals(expectedTasks));
        expect(notifier.state.error, isNull);
        verify(mockGetTasks(any)).called(1);
      });

      test('should handle loading state correctly', () async {
        // Arrange
        when(mockGetTasks(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = notifier.loadTasks();

        // Assert - should be loading
        expect(notifier.state.isLoading, true);

        await future;

        // Assert - should not be loading after completion
        expect(notifier.state.isLoading, false);
      });

      test('should handle failure correctly', () async {
        // Arrange
        when(
          mockGetTasks(any),
        ).thenThrow(const CacheFailure(message: 'Database error'));

        // Act
        await notifier.loadTasks();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.tasks, isEmpty);
        expect(notifier.state.error, contains('Error de caché'));
      });

      test('should handle unexpected error correctly', () async {
        // Arrange
        when(mockGetTasks(any)).thenThrow(Exception('Unexpected error'));

        // Act
        await notifier.loadTasks();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.tasks, isEmpty);
        expect(notifier.state.error, contains('Error inesperado'));
      });
    });

    group('addTask', () {
      test('should add task successfully', () async {
        // Arrange
        final newTask = Task(
          id: null,
          title: 'New Task',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        when(mockAddTask(any)).thenAnswer((_) async => Future.value());
        when(
          mockGetTasks(any),
        ).thenAnswer((_) async => [newTask.copyWith(id: 1)]);

        // Act
        await notifier.addTask(newTask);

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, isNull);
        verify(mockAddTask(any)).called(1);
        verify(mockGetTasks(any)).called(1);
      });

      test('should handle add task failure', () async {
        // Arrange
        final newTask = Task(
          id: null,
          title: 'New Task',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        when(
          mockAddTask(any),
        ).thenThrow(const CacheFailure(message: 'Add task failed'));

        // Act
        await notifier.addTask(newTask);

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, contains('Error de caché'));
      });
    });

    group('updateTask', () {
      test('should update task successfully', () async {
        // Arrange
        final existingTask = Task(
          id: 1,
          title: 'Original Task',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final updatedTask = existingTask.copyWith(
          title: 'Updated Task',
          isCompleted: true,
          updatedAt: DateTime.now(),
        );

        when(mockUpdateTask(any)).thenAnswer((_) async => Future.value());

        // Act
        await notifier.updateTask(updatedTask);

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, isNull);
        verify(mockUpdateTask(any)).called(1);
      });

      test('should handle update task failure', () async {
        // Arrange
        final task = Task(
          id: 1,
          title: 'Task',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        when(
          mockUpdateTask(any),
        ).thenThrow(const CacheFailure(message: 'Update failed'));

        // Act
        await notifier.updateTask(task);

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, contains('Error de caché'));
      });
    });

    group('deleteTask', () {
      test('should delete task successfully', () async {
        // Arrange
        const taskId = 1;

        when(mockDeleteTask(any)).thenAnswer((_) async => Future.value());

        // Act
        await notifier.deleteTask(taskId);

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, isNull);
        verify(mockDeleteTask(any)).called(1);
      });

      test('should handle delete task failure', () async {
        // Arrange
        const taskId = 1;

        when(
          mockDeleteTask(any),
        ).thenThrow(const CacheFailure(message: 'Delete failed'));

        // Act
        await notifier.deleteTask(taskId);

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, contains('Error de caché'));
      });
    });

    group('markTaskAsCompleted', () {
      test('should mark task as completed successfully', () async {
        // Arrange
        const taskId = 1;

        when(mockUpdateTask(any)).thenAnswer((_) async => Future.value());
        when(mockGetTasks(any)).thenAnswer((_) async => []);

        // Act
        await notifier.markTaskAsCompleted(taskId);

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, isNull);
        verify(mockUpdateTask(any)).called(1);
        verify(mockGetTasks(any)).called(1);
      });
    });

    group('markTaskAsPending', () {
      test('should mark task as pending successfully', () async {
        // Arrange
        const taskId = 1;

        when(mockUpdateTask(any)).thenAnswer((_) async => Future.value());
        when(mockGetTasks(any)).thenAnswer((_) async => []);

        // Act
        await notifier.markTaskAsPending(taskId);

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, isNull);
        verify(mockUpdateTask(any)).called(1);
        verify(mockGetTasks(any)).called(1);
      });
    });

    group('updateTaskTitle', () {
      test('should update task title successfully', () async {
        // Arrange
        const taskId = 1;
        const newTitle = 'New Title';

        when(mockUpdateTask(any)).thenAnswer((_) async => Future.value());
        when(mockGetTasks(any)).thenAnswer((_) async => []);

        // Act
        await notifier.updateTaskTitle(taskId, newTitle);

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, isNull);
        verify(mockUpdateTask(any)).called(1);
        verify(mockGetTasks(any)).called(1);
      });
    });

    group('clearError', () {
      test('should clear error from state', () {
        // Arrange
        notifier.state = notifier.state.withError('Test error');
        expect(notifier.state.error, isNotNull);

        // Act
        notifier.clearError();

        // Assert
        expect(notifier.state.error, isNull);
      });
    });

    group('refresh', () {
      test('should call loadTasks', () async {
        // Arrange
        when(mockGetTasks(any)).thenAnswer((_) async => []);

        // Act
        await notifier.refresh();

        // Assert
        verify(mockGetTasks(any)).called(1);
      });
    });

    group('State Methods', () {
      test('should create loading state correctly', () {
        // Arrange
        final initialState = const TaskListState(tasks: []);

        // Act
        final loadingState = initialState.loading();

        // Assert
        expect(loadingState.isLoading, true);
        expect(loadingState.tasks, isEmpty);
        expect(loadingState.error, isNull);
      });

      test('should create state with tasks correctly', () {
        // Arrange
        final tasks = [
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

        // Act
        final stateWithTasks = const TaskListState().withTasks(tasks);

        // Assert
        expect(stateWithTasks.isLoading, false);
        expect(stateWithTasks.tasks, equals(tasks));
        expect(stateWithTasks.error, isNull);
      });

      test('should create state with error correctly', () {
        // Arrange
        const errorMessage = 'Test error';

        // Act
        final stateWithError = const TaskListState().withError(errorMessage);

        // Assert
        expect(stateWithError.isLoading, false);
        expect(stateWithError.tasks, isEmpty);
        expect(stateWithError.error, equals(errorMessage));
      });

      test('should create state with task added correctly', () {
        // Arrange
        final existingTasks = [
          Task(
            id: 1,
            title: 'Task 1',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ];
        final newTask = Task(
          id: 2,
          title: 'Task 2',
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        final initialState = const TaskListState().withTasks(existingTasks);

        // Act
        final stateWithTaskAdded = initialState.withTaskAdded(newTask);

        // Assert
        expect(stateWithTaskAdded.isLoading, false);
        expect(stateWithTaskAdded.tasks.length, 2);
        expect(stateWithTaskAdded.tasks.last, equals(newTask));
        expect(stateWithTaskAdded.error, isNull);
      });

      test('should create state with task updated correctly', () {
        // Arrange
        final tasks = [
          Task(
            id: 1,
            title: 'Task 1',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          Task(
            id: 2,
            title: 'Task 2',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ];
        final updatedTask = Task(
          id: 1,
          title: 'Updated Task 1',
          isCompleted: true,
          createdAt: DateTime.now(),
        );
        final initialState = const TaskListState().withTasks(tasks);

        // Act
        final stateWithTaskUpdated = initialState.withTaskUpdated(updatedTask);

        // Assert
        expect(stateWithTaskUpdated.isLoading, false);
        expect(stateWithTaskUpdated.tasks.length, 2);
        expect(stateWithTaskUpdated.tasks.first, equals(updatedTask));
        expect(stateWithTaskUpdated.error, isNull);
      });

      test('should create state with task deleted correctly', () {
        // Arrange
        final tasks = [
          Task(
            id: 1,
            title: 'Task 1',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          Task(
            id: 2,
            title: 'Task 2',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ];
        final initialState = const TaskListState().withTasks(tasks);

        // Act
        final stateWithTaskDeleted = initialState.withTaskDeleted(1);

        // Assert
        expect(stateWithTaskDeleted.isLoading, false);
        expect(stateWithTaskDeleted.tasks.length, 1);
        expect(stateWithTaskDeleted.tasks.first.id, 2);
        expect(stateWithTaskDeleted.error, isNull);
      });
    });

    group('Stats', () {
      test('should calculate stats correctly', () {
        // Arrange
        final tasks = [
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
          Task(
            id: 3,
            title: 'Task 3',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          Task(
            id: 4,
            title: 'Task 4',
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
        ];
        final state = const TaskListState().withTasks(tasks);

        // Act
        final stats = state.stats;

        // Assert
        expect(stats.total, 4);
        expect(stats.completed, 2);
        expect(stats.pending, 2);
        expect(stats.completionPercentage, 50.0);
      });

      test('should handle empty tasks stats correctly', () {
        // Arrange
        const state = TaskListState();

        // Act
        final stats = state.stats;

        // Assert
        expect(stats.total, 0);
        expect(stats.completed, 0);
        expect(stats.pending, 0);
        expect(stats.completionPercentage, 0.0);
      });
    });

    group('Getters', () {
      test('should return correct values for getters', () {
        // Arrange
        final tasks = [
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
        final state = const TaskListState().withTasks(tasks);

        // Act & Assert
        expect(state.hasTasks, true);
        expect(state.hasError, false);
        expect(state.pendingTasks.length, 1);
        expect(state.completedTasks.length, 1);
      });
    });
  });
}
