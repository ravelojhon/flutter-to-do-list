# TaskListNotifier - State Management con Riverpod

El `TaskListNotifier` es un `StateNotifier` que maneja el estado de la lista de tareas en la aplicación Flutter usando Riverpod.

## 📁 Archivos

- `task_list_notifier.dart` - Implementación principal del notifier
- `task_list_notifier_example.dart` - Ejemplos de uso
- `task_list_notifier_test.dart` - Tests unitarios

## 🏗️ Arquitectura

### TaskListState
```dart
class TaskListState {
  final bool isLoading;
  final List<Task> tasks;
  final String? error;
}
```

### TaskListNotifier
```dart
class TaskListNotifier extends StateNotifier<TaskListState> {
  // Métodos para manejar el estado
}
```

## 🚀 Características

- ✅ **State Management** - Manejo completo del estado con Riverpod
- ✅ **Loading States** - Estados de carga durante operaciones
- ✅ **Error Handling** - Manejo de errores con mensajes legibles
- ✅ **CRUD Operations** - Operaciones completas de tareas
- ✅ **Statistics** - Estadísticas automáticas de tareas
- ✅ **Reactive Updates** - Actualizaciones reactivas del UI
- ✅ **Type Safety** - Tipado fuerte con Dart

## 📋 Métodos Disponibles

### Operaciones Principales

#### loadTasks()
```dart
await notifier.loadTasks();
```
- Carga todas las tareas desde el repositorio
- Maneja estados de carga y error
- Actualiza el estado con las tareas obtenidas

#### addTask(Task task)
```dart
final newTask = Task(
  id: null,
  title: 'Nueva tarea',
  isCompleted: false,
  createdAt: DateTime.now(),
);
await notifier.addTask(newTask);
```
- Agrega una nueva tarea
- Valida parámetros de entrada
- Recarga la lista después de agregar

#### updateTask(Task task)
```dart
final updatedTask = task.copyWith(
  title: 'Título actualizado',
  isCompleted: true,
  updatedAt: DateTime.now(),
);
await notifier.updateTask(updatedTask);
```
- Actualiza una tarea existente
- Requiere que la tarea tenga un ID válido
- Actualiza el estado local inmediatamente

#### deleteTask(int taskId)
```dart
await notifier.deleteTask(1);
```
- Elimina una tarea por ID
- Actualiza el estado local inmediatamente
- Maneja errores si la tarea no existe

### Operaciones Específicas

#### markTaskAsCompleted(int taskId)
```dart
await notifier.markTaskAsCompleted(1);
```
- Marca una tarea como completada
- Actualiza la fecha de modificación
- Recarga la lista para obtener el estado actualizado

#### markTaskAsPending(int taskId)
```dart
await notifier.markTaskAsPending(1);
```
- Marca una tarea como pendiente
- Actualiza la fecha de modificación
- Recarga la lista para obtener el estado actualizado

#### updateTaskTitle(int taskId, String newTitle)
```dart
await notifier.updateTaskTitle(1, 'Nuevo título');
```
- Actualiza solo el título de una tarea
- Valida que el título no esté vacío
- Recarga la lista para obtener el título actualizado

### Utilidades

#### clearError()
```dart
notifier.clearError();
```
- Limpia el error del estado
- Útil para ocultar mensajes de error

#### refresh()
```dart
await notifier.refresh();
```
- Recarga todas las tareas
- Equivalente a `loadTasks()`

## 🔧 Estados del TaskListState

### Estado Inicial
```dart
const TaskListState(
  isLoading: false,
  tasks: [],
  error: null,
);
```

### Estado de Carga
```dart
state.loading()
// isLoading: true, tasks: [mantiene tareas existentes], error: null
```

### Estado con Tareas
```dart
state.withTasks([task1, task2, task3])
// isLoading: false, tasks: [task1, task2, task3], error: null
```

### Estado con Error
```dart
state.withError('Mensaje de error')
// isLoading: false, tasks: [mantiene tareas existentes], error: 'Mensaje de error'
```

### Estado con Tarea Agregada
```dart
state.withTaskAdded(newTask)
// isLoading: false, tasks: [...existingTasks, newTask], error: null
```

### Estado con Tarea Actualizada
```dart
state.withTaskUpdated(updatedTask)
// isLoading: false, tasks: [tareas con la actualizada], error: null
```

### Estado con Tarea Eliminada
```dart
state.withTaskDeleted(taskId)
// isLoading: false, tasks: [tareas sin la eliminada], error: null
```

## 📊 Estadísticas Automáticas

### TaskListStats
```dart
class TaskListStats {
  final int total;
  final int completed;
  final int pending;
  final double completionPercentage;
}
```

### Getters Disponibles
```dart
// Obtener estadísticas
final stats = state.stats;

// Verificar si hay tareas
final hasTasks = state.hasTasks;

// Verificar si hay error
final hasError = state.hasError;

// Obtener tareas pendientes
final pendingTasks = state.pendingTasks;

// Obtener tareas completadas
final completedTasks = state.completedTasks;
```

## 🎯 Providers de Riverpod

### Provider Principal
```dart
final taskListNotifierProvider = StateNotifierProvider<TaskListNotifier, TaskListState>((ref) {
  // Inyectar dependencias aquí
  throw UnimplementedError('Los use cases deben ser inyectados aquí');
});
```

### Providers Derivados
```dart
// Solo las tareas
final tasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskListNotifierProvider).tasks;
});

// Tareas pendientes
final pendingTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskListNotifierProvider).pendingTasks;
});

// Tareas completadas
final completedTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskListNotifierProvider).completedTasks;
});

// Estadísticas
final taskListStatsProvider = Provider<TaskListStats>((ref) {
  return ref.watch(taskListNotifierProvider).stats;
});

// Estado de carga
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(taskListNotifierProvider).isLoading;
});

// Error
final taskListErrorProvider = Provider<String?>((ref) {
  return ref.watch(taskListNotifierProvider).error;
});
```

## 🧪 Uso en Widgets

### Widget Básico
```dart
class TaskListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListState = ref.watch(taskListNotifierProvider);
    final notifier = ref.read(taskListNotifierProvider.notifier);

    return Column(
      children: [
        if (taskListState.isLoading) LinearProgressIndicator(),
        if (taskListState.error != null) Text('Error: ${taskListState.error}'),
        Expanded(
          child: ListView.builder(
            itemCount: taskListState.tasks.length,
            itemBuilder: (context, index) {
              final task = taskListState.tasks[index];
              return ListTile(
                title: Text(task.title),
                trailing: IconButton(
                  onPressed: () => notifier.deleteTask(task.id!),
                  icon: Icon(Icons.delete),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

### Widget con Providers Derivados
```dart
class TaskStatsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(taskListStatsProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Total: ${stats.total}'),
            Text('Completadas: ${stats.completed}'),
            Text('Pendientes: ${stats.pending}'),
            Text('Progreso: ${stats.completionPercentage.toStringAsFixed(1)}%'),
            if (isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
```

## 🚨 Manejo de Errores

### Tipos de Errores
- **ServerFailure** → "Error del servidor: {mensaje}"
- **CacheFailure** → "Error de caché: {mensaje}"
- **UnexpectedFailure** → "Error inesperado: {mensaje}"

### Limpiar Errores
```dart
// Limpiar error manualmente
notifier.clearError();

// Los errores se limpian automáticamente en operaciones exitosas
```

## 🧪 Testing

### Ejecutar Tests
```bash
flutter test lib/presentation/providers/task_list_notifier_test.dart
```

### Ejemplo de Test
```dart
test('should load tasks successfully', () async {
  // Arrange
  final expectedTasks = [task1, task2];
  when(mockGetTasks(any)).thenAnswer((_) async => expectedTasks);

  // Act
  await notifier.loadTasks();

  // Assert
  expect(notifier.state.tasks, equals(expectedTasks));
  expect(notifier.state.isLoading, false);
  expect(notifier.state.error, isNull);
});
```

## 📝 Notas Importantes

1. **Inyección de Dependencias** - Los use cases deben ser inyectados en el provider
2. **Manejo de Estados** - El notifier maneja automáticamente los estados de carga
3. **Actualizaciones Reactivas** - Los widgets se actualizan automáticamente cuando cambia el estado
4. **Manejo de Errores** - Los errores se convierten en mensajes legibles para el usuario
5. **Operaciones Atómicas** - Cada operación es independiente y maneja su propio estado

## 🚀 Próximos Pasos

- [ ] Agregar filtros por estado
- [ ] Implementar búsqueda en tiempo real
- [ ] Agregar paginación
- [ ] Implementar sincronización offline
- [ ] Agregar animaciones de transición
