# Use Cases - Capa de Dominio

Los Use Cases representan la lógica de negocio de la aplicación y actúan como intermediarios entre la capa de presentación y la capa de datos.

## 📁 Archivos

- `get_tasks.dart` - Use cases para obtener tareas
- `add_task.dart` - Use cases para agregar tareas
- `update_task.dart` - Use cases para actualizar tareas
- `delete_task.dart` - Use cases para eliminar tareas
- `usecases_example.dart` - Ejemplos de uso
- `usecases_test.dart` - Tests unitarios

## 🏗️ Arquitectura

### Patrón Use Case
```dart
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}
```

### Características
- ✅ **Inyección de Dependencias** - Reciben TaskRepository en constructor
- ✅ **Manejo de Errores** - Convierten excepciones en Failures
- ✅ **Validaciones** - Validan parámetros de entrada
- ✅ **Lógica de Negocio** - Contienen reglas de negocio específicas
- ✅ **Testeable** - Fáciles de testear con mocks

## 📋 Use Cases Disponibles

### 1. GetTasks - Obtener Tareas

#### GetTasks
```dart
final getTasks = GetTasks(repository);
final tasks = await getTasks(NoParams());
```

#### GetTasksByStatus
```dart
final getTasksByStatus = GetTasksByStatus(repository);
final pendingTasks = await getTasksByStatus(false);
final completedTasks = await getTasksByStatus(true);
```

#### GetPendingTasks
```dart
final getPendingTasks = GetPendingTasks(repository);
final pending = await getPendingTasks(NoParams());
```

#### GetCompletedTasks
```dart
final getCompletedTasks = GetCompletedTasks(repository);
final completed = await getCompletedTasks(NoParams());
```

#### SearchTasks
```dart
final searchTasks = SearchTasks(repository);
final results = await searchTasks('Flutter');
```

#### GetRecentTasks
```dart
final getRecentTasks = GetRecentTasks(repository);
final recent = await getRecentTasks(10);
```

#### GetTaskStats
```dart
final getTaskStats = GetTaskStats(repository);
final stats = await getTaskStats(NoParams());
```

### 2. AddTask - Agregar Tareas

#### AddTask
```dart
final addTask = AddTask(repository);
final params = AddTaskParams(
  title: 'Nueva tarea',
  isCompleted: false,
  createdAt: DateTime.now(),
);
await addTask(params);
```

#### AddTaskWithValidation
```dart
final addTaskWithValidation = AddTaskWithValidation(repository);
final params = AddTaskParams(title: 'Tarea validada');
await addTaskWithValidation(params);
```

#### AddMultipleTasks
```dart
final addMultipleTasks = AddMultipleTasks(repository);
final params = [
  AddTaskParams(title: 'Tarea 1'),
  AddTaskParams(title: 'Tarea 2'),
];
await addMultipleTasks(params);
```

### 3. UpdateTask - Actualizar Tareas

#### UpdateTask
```dart
final updateTask = UpdateTask(repository);
final params = UpdateTaskParams(
  id: 1,
  title: 'Título actualizado',
  isCompleted: true,
  updatedAt: DateTime.now(),
);
await updateTask(params);
```

#### UpdateTaskTitle
```dart
final updateTaskTitle = UpdateTaskTitle(repository);
final params = UpdateTaskParams.updateTitle(1, 'Nuevo título');
await updateTaskTitle(params);
```

#### MarkTaskAsCompleted
```dart
final markAsCompleted = MarkTaskAsCompleted(repository);
await markAsCompleted(1);
```

#### MarkTaskAsPending
```dart
final markAsPending = MarkTaskAsPending(repository);
await markAsPending(1);
```

#### UpdateMultipleTasks
```dart
final updateMultipleTasks = UpdateMultipleTasks(repository);
final params = [
  UpdateTaskParams(id: 1, title: 'Actualizada 1'),
  UpdateTaskParams(id: 2, title: 'Actualizada 2'),
];
await updateMultipleTasks(params);
```

### 4. DeleteTask - Eliminar Tareas

#### DeleteTask
```dart
final deleteTask = DeleteTask(repository);
final params = DeleteTaskParams(id: 1, force: false);
await deleteTask(params);
```

#### DeleteTaskById
```dart
final deleteTaskById = DeleteTaskById(repository);
await deleteTaskById(1);
```

#### DeleteMultipleTasks
```dart
final deleteMultipleTasks = DeleteMultipleTasks(repository);
final taskIds = [1, 2, 3];
await deleteMultipleTasks(taskIds);
```

#### DeleteCompletedTasks
```dart
final deleteCompletedTasks = DeleteCompletedTasks(repository);
final deletedCount = await deleteCompletedTasks(NoParams());
```

#### DeleteTasksByDateRange
```dart
final deleteTasksByDateRange = DeleteTasksByDateRange(repository);
final params = DateRangeParams(
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 1, 31),
);
final deletedCount = await deleteTasksByDateRange(params);
```

#### DeleteTaskWithConfirmation
```dart
final deleteTaskWithConfirmation = DeleteTaskWithConfirmation(repository);
final params = DeleteTaskParams(id: 1, force: false);
await deleteTaskWithConfirmation(params);
```

## 🔧 Parámetros

### AddTaskParams
```dart
class AddTaskParams {
  final String title;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### UpdateTaskParams
```dart
class UpdateTaskParams {
  final int id;
  final String? title;
  final bool? isCompleted;
  final DateTime? updatedAt;
}
```

### DeleteTaskParams
```dart
class DeleteTaskParams {
  final int id;
  final bool force;
}
```

### DateRangeParams
```dart
class DateRangeParams {
  final DateTime startDate;
  final DateTime endDate;
}
```

## 🚨 Validaciones

### AddTask
- ✅ Título no puede estar vacío
- ✅ Título no puede exceder 200 caracteres
- ✅ Fecha de creación no puede ser futura
- ✅ Fecha de actualización no puede ser futura
- ✅ Fecha de actualización no puede ser anterior a creación

### UpdateTask
- ✅ ID debe ser válido (> 0)
- ✅ Tarea debe existir
- ✅ Título no puede estar vacío (si se proporciona)
- ✅ Título no puede exceder 200 caracteres
- ✅ Fecha de actualización no puede ser futura

### DeleteTask
- ✅ ID debe ser válido (> 0)
- ✅ Tarea debe existir (si no es eliminación forzada)
- ✅ Máximo 50 tareas por operación múltiple

### SearchTasks
- ✅ Query no puede estar vacía

### GetRecentTasks
- ✅ Límite debe ser mayor que 0

## 🧪 Testing

### Ejecutar Tests
```bash
flutter test lib/domain/usecases/usecases_test.dart
```

### Ejecutar Ejemplos
```dart
final example = UseCasesExample();
await example.runAllExamples();
```

## 📊 Flujo de Datos

```
Presentation Layer
    ↓
Use Cases (Domain)
    ↓
TaskRepository (Interface)
    ↓
TaskRepositoryImpl (Data)
    ↓
Drift Database
```

## 🎯 Ventajas

- ✅ **Separación de Responsabilidades** - Lógica de negocio aislada
- ✅ **Reutilización** - Use cases pueden ser reutilizados
- ✅ **Testabilidad** - Fáciles de testear independientemente
- ✅ **Mantenibilidad** - Cambios de lógica centralizados
- ✅ **Validaciones** - Reglas de negocio consistentes
- ✅ **Manejo de Errores** - Errores tipados y manejables

## 📝 Notas Importantes

1. **Inyección de Dependencias** - Siempre inyectar TaskRepository
2. **Manejo de Errores** - Usar try-catch para manejar Failures
3. **Validaciones** - Los use cases validan parámetros de entrada
4. **Lógica de Negocio** - Contienen reglas específicas del dominio
5. **Testing** - Usar mocks para testear independientemente

## 🚀 Próximos Pasos

- [ ] Agregar use cases para operaciones en lote
- [ ] Implementar use cases para sincronización
- [ ] Agregar use cases para métricas avanzadas
- [ ] Implementar use cases para notificaciones
