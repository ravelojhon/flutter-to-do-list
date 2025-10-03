import 'package:flutter_test/flutter_test.dart';
import '../../domain/entities/task.dart';
import 'task_list_notifier.dart';

void main() {
  group('TaskListState Tests', () {
    test('should create initial state correctly', () {
      // Act
      const state = TaskListState();

      // Assert
      expect(state.isLoading, false);
      expect(state.tasks, isEmpty);
      expect(state.error, isNull);
    });

    test('should create loading state correctly', () {
      // Arrange
      const initialState = TaskListState(tasks: []);

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

    test('should clear error correctly', () {
      // Arrange
      const stateWithError = TaskListState(error: 'Test error');

      // Act
      final clearedState = stateWithError.clearError();

      // Assert
      expect(clearedState.isLoading, false);
      expect(clearedState.tasks, isEmpty);
      expect(clearedState.error, isNull);
    });
  });

  group('TaskListStats Tests', () {
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

    test('should handle all completed tasks correctly', () {
      // Arrange
      final tasks = [
        Task(
          id: 1,
          title: 'Task 1',
          isCompleted: true,
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

      // Act
      final stats = state.stats;

      // Assert
      expect(stats.total, 2);
      expect(stats.completed, 2);
      expect(stats.pending, 0);
      expect(stats.completionPercentage, 100.0);
    });

    test('should handle all pending tasks correctly', () {
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
      final state = const TaskListState().withTasks(tasks);

      // Act
      final stats = state.stats;

      // Assert
      expect(stats.total, 2);
      expect(stats.completed, 0);
      expect(stats.pending, 2);
      expect(stats.completionPercentage, 0.0);
    });
  });

  group('TaskListState Getters Tests', () {
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

    test('should return correct values for empty state', () {
      // Arrange
      const state = TaskListState();

      // Act & Assert
      expect(state.hasTasks, false);
      expect(state.hasError, false);
      expect(state.pendingTasks, isEmpty);
      expect(state.completedTasks, isEmpty);
    });

    test('should return correct values for state with error', () {
      // Arrange
      const state = TaskListState(error: 'Test error');

      // Act & Assert
      expect(state.hasTasks, false);
      expect(state.hasError, true);
      expect(state.pendingTasks, isEmpty);
      expect(state.completedTasks, isEmpty);
    });
  });

  group('TaskListState Equality Tests', () {
    test('should be equal when all properties are same', () {
      // Arrange
      final tasks = [
        Task(
          id: 1,
          title: 'Task 1',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];
      final state1 = const TaskListState().withTasks(tasks);
      final state2 = const TaskListState().withTasks(tasks);

      // Act & Assert
      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('should not be equal when properties are different', () {
      // Arrange
      final tasks1 = [
        Task(
          id: 1,
          title: 'Task 1',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];
      final tasks2 = [
        Task(
          id: 2,
          title: 'Task 2',
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
      ];
      final state1 = const TaskListState().withTasks(tasks1);
      final state2 = const TaskListState().withTasks(tasks2);

      // Act & Assert
      expect(state1, isNot(equals(state2)));
    });
  });

  group('TaskListStats Equality Tests', () {
    test('should be equal when all properties are same', () {
      // Arrange
      const stats1 = TaskListStats(
        total: 10,
        completed: 5,
        pending: 5,
        completionPercentage: 50.0,
      );
      const stats2 = TaskListStats(
        total: 10,
        completed: 5,
        pending: 5,
        completionPercentage: 50.0,
      );

      // Act & Assert
      expect(stats1, equals(stats2));
    });

    test('should not be equal when properties are different', () {
      // Arrange
      const stats1 = TaskListStats(
        total: 10,
        completed: 5,
        pending: 5,
        completionPercentage: 50.0,
      );
      const stats2 = TaskListStats(
        total: 10,
        completed: 6,
        pending: 4,
        completionPercentage: 60.0,
      );

      // Act & Assert
      expect(stats1, isNot(equals(stats2)));
    });
  });
}
