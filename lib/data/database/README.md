# Base de Datos Drift - AppDatabase

Este directorio contiene la configuración de la base de datos usando Drift (anteriormente Moor) para Flutter.

## 📁 Archivos

- `app_database.dart` - Definición de la base de datos, tablas y DAO
- `database_example.dart` - Ejemplos de uso del DAO
- `app_database.g.dart` - Código generado por Drift (NO EDITAR)

## 🗄️ Estructura de la Base de Datos

### Tabla: Tasks
| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | INTEGER | Clave primaria auto-incremental |
| `title` | TEXT | Título de la tarea |
| `is_completed` | BOOLEAN | Estado de completado (default: false) |
| `created_at` | INTEGER | Timestamp de creación |
| `updated_at` | INTEGER | Timestamp de actualización (nullable) |

## 🔧 Compilación con Build Runner

### 1. Instalar Dependencias
```bash
flutter pub get
```

### 2. Generar Código
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Modo Watch (Desarrollo)
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 4. Limpiar y Regenerar
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## 📝 Uso Básico

```dart
import 'app_database.dart';

// Inicializar base de datos
final database = AppDatabase();

// Obtener DAO
final tasksDao = database.tasksDao;

// Insertar tarea
final taskId = await tasksDao.insertTaskData(
  title: 'Mi nueva tarea',
  isCompleted: false,
  createdAt: DateTime.now(),
);

// Obtener todas las tareas
final tasks = await tasksDao.getAllTasks();

// Actualizar tarea
await tasksDao.updateTaskById(
  taskId,
  title: 'Tarea actualizada',
  isCompleted: true,
  updatedAt: DateTime.now(),
);

// Eliminar tarea
await tasksDao.deleteTask(taskId);

// Cerrar base de datos
await database.close();
```

## 🚨 Solución de Problemas

### Error: "Could not resolve annotation"
- Ejecutar `flutter clean` y `flutter pub get`
- Verificar que todas las dependencias estén instaladas

### Error: "Build failed"
- Verificar que el archivo tenga las anotaciones correctas
- Ejecutar con `--delete-conflicting-outputs`

### Error: "Database is locked"
- Asegurarse de cerrar la base de datos con `database.close()`
- Verificar que no haya múltiples instancias abiertas

## 📚 Recursos Adicionales

- [Documentación de Drift](https://drift.simonbinder.eu/)
- [Guía de Migraciones](https://drift.simonbinder.eu/docs/getting-started/writing_queries/)
- [Ejemplos de DAO](https://drift.simonbinder.eu/docs/getting-started/writing_queries/#daos)
