# TaskRepository - Implementación con Drift

Este directorio contiene la implementación del repositorio de tareas usando Drift como base de datos local.

## 📁 Archivos

- `task_repository_impl.dart` - Implementación del repositorio
- `task_repository_example.dart` - Ejemplos de uso
- `task_repository_test.dart` - Tests unitarios

## 🏗️ Arquitectura

### TaskRepository (Interfaz)
```dart
abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(int id);
  Future<Task?> getTaskById(int id);
  Future<List<Task>> getTasksByStatus(bool isCompleted);
  Future<List<Task>> searchTasks(String query);
  Future<List<Task>> getRecentTasks(int limit);
  Future<TaskStats> getTaskStats();
}
```

### TaskRepositoryImpl (Implementación)
- ✅ **Manejo de Excepciones** - Convierte excepciones a Failures
- ✅ **Validaciones** - Valida datos antes de operaciones
- ✅ **Conversiones** - Usa TaskModel para conversiones con Drift
- ✅ **Operaciones Avanzadas** - Métodos adicionales para funcionalidad extendida

## 🔧 Uso Básico

### Inicialización
```dart
final database = AppDatabase();
final repository = TaskRepositoryImpl(database);
```

### Operaciones CRUD
```dart
// Agregar tarea
await repository.addTask(Task(
  id: null,
  title: 'Nueva tarea',
  isCompleted: false,
  createdAt: DateTime.now(),
));

// Obtener todas las tareas
final tasks = await repository.getAllTasks();

// Actualizar tarea
final updatedTask = task.copyWith(
  title: 'Título actualizado',
  isCompleted: true,
  updatedAt: DateTime.now(),
);
await repository.updateTask(updatedTask);

// Eliminar tarea
await repository.deleteTask(taskId);
```

### Filtros y Búsquedas
```dart
// Obtener tareas por estado
final pendingTasks = await repository.getPendingTasks();
final completedTasks = await repository.getCompletedTasks();

// Buscar tareas
final searchResults = await repository.searchTasks('Flutter');

// Obtener tareas recientes
final recentTasks = await repository.getRecentTasks(10);

// Obtener estadísticas
final stats = await repository.getTaskStats();
print('Total: ${stats.total}, Completadas: ${stats.completed}');
```

## 🚨 Manejo de Errores

El repositorio convierte automáticamente las excepciones en Failures:

```dart
try {
  await repository.addTask(task);
} on CacheFailure catch (e) {
  print('Error de caché: ${e.message}');
} on ServerFailure catch (e) {
  print('Error del servidor: ${e.message}');
} on UnexpectedFailure catch (e) {
  print('Error inesperado: ${e.message}');
}
```

### Tipos de Errores
- **CacheFailure** - Errores de base de datos local
- **ServerFailure** - Errores de red/servidor
- **UnexpectedFailure** - Errores no categorizados

## 📊 Operaciones Avanzadas

### Operaciones en Lote
```dart
// Eliminar todas las tareas completadas
final deletedCount = await repository.deleteCompletedTasks();
print('$deletedCount tareas eliminadas');
```

### Filtros por Fecha
```dart
final startDate = DateTime(2024, 1, 1);
final endDate = DateTime(2024, 1, 31);
final tasksInRange = await repository.getTasksByDateRange(startDate, endDate);
```

### Actualizaciones Específicas
```dart
// Marcar como completada
await repository.markTaskAsCompleted(taskId);

// Marcar como pendiente
await repository.markTaskAsPending(taskId);

// Actualizar solo el título
await repository.updateTaskTitle(taskId, 'Nuevo título');
```

## 🧪 Testing

### Ejecutar Tests
```bash
flutter test lib/data/repositories/task_repository_test.dart
```

### Ejecutar Ejemplos
```dart
final example = TaskRepositoryExample();
await example.runAllExamples();
```

## 🔄 Flujo de Datos

```
Task (Domain) 
    ↓
TaskRepository (Interface)
    ↓
TaskRepositoryImpl (Implementation)
    ↓
TasksDaoEnhanced (DAO)
    ↓
TaskModel (Data Model)
    ↓
Drift Database (SQLite)
```

## 📝 Notas Importantes

1. **Cierre de Recursos** - Siempre cerrar el repositorio:
   ```dart
   await repository.close();
   ```

2. **Validaciones** - El repositorio valida:
   - IDs requeridos para actualizaciones
   - Títulos no vacíos
   - Límites válidos para consultas
   - Rangos de fechas correctos

3. **Conversiones** - Usa TaskModel internamente para:
   - Convertir entre Task (domain) y Drift
   - Manejar timestamps como enteros
   - Serialización/deserialización

4. **Manejo de Errores** - Todas las excepciones se convierten en Failures apropiados

## 🚀 Próximos Pasos

- [ ] Implementar caché en memoria
- [ ] Agregar sincronización con servidor
- [ ] Implementar paginación
- [ ] Agregar métricas de rendimiento
