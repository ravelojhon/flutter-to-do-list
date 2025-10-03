import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

/// Tabla de tareas
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer().nullable()();
}

/// Data Access Object para tareas
@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(AppDatabase db) : super(db);

  /// Obtener todas las tareas
  Future<List<Task>> getAllTasks() async {
    return await select(tasks).get();
  }

  /// Obtener tarea por ID
  Future<Task?> getTaskById(int id) async {
    return await (select(
      tasks,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Obtener tareas por estado
  Future<List<Task>> getTasksByStatus(bool isCompleted) async {
    return await (select(
      tasks,
    )..where((tbl) => tbl.isCompleted.equals(isCompleted))).get();
  }

  /// Insertar nueva tarea
  Future<int> insertTask(TasksCompanion task) async {
    return await into(tasks).insert(task);
  }

  /// Insertar tarea con datos completos
  Future<int> insertTaskData({
    required String title,
    bool isCompleted = false,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) async {
    return await into(tasks).insert(
      TasksCompanion(
        title: Value(title),
        isCompleted: Value(isCompleted),
        createdAt: Value(createdAt.millisecondsSinceEpoch),
        updatedAt: Value(updatedAt?.millisecondsSinceEpoch),
      ),
    );
  }

  /// Actualizar tarea
  Future<bool> updateTask(Task task) async {
    return await update(tasks).replace(task);
  }

  /// Actualizar tarea por ID
  Future<bool> updateTaskById(
    int id, {
    String? title,
    bool? isCompleted,
    DateTime? updatedAt,
  }) async {
    final query = update(tasks)..where((tbl) => tbl.id.equals(id));

    final result = await query.write(
      TasksCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        isCompleted: isCompleted != null
            ? Value(isCompleted)
            : const Value.absent(),
        updatedAt: updatedAt != null
            ? Value(updatedAt.millisecondsSinceEpoch)
            : const Value.absent(),
      ),
    );

    return result > 0;
  }

  /// Eliminar tarea
  Future<bool> deleteTask(int id) async {
    return await (delete(tasks)..where((tbl) => tbl.id.equals(id))).go() > 0;
  }

  /// Eliminar todas las tareas completadas
  Future<int> deleteCompletedTasks() async {
    return await (delete(
      tasks,
    )..where((tbl) => tbl.isCompleted.equals(true))).go();
  }

  /// Obtener estadísticas de tareas
  Future<TaskStats> getTaskStats() async {
    final allTasks = await getAllTasks();
    final total = allTasks.length;
    final completed = allTasks.where((task) => task.isCompleted).length;
    final pending = total - completed;

    return TaskStats(total: total, completed: completed, pending: pending);
  }

  /// Buscar tareas por título
  Future<List<Task>> searchTasks(String query) async {
    return await (select(
      tasks,
    )..where((tbl) => tbl.title.contains(query))).get();
  }
}

/// Estadísticas de tareas
class TaskStats {
  final int total;
  final int completed;
  final int pending;

  const TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
  });

  double get completionPercentage {
    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }
}

/// Base de datos principal de la aplicación
@DriftDatabase(tables: [Tasks], daos: [TasksDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Aquí puedes agregar migraciones futuras
    },
  );

  /// Obtener DAO de tareas
  TasksDao get tasksDao => TasksDao(this);
}

/// Configurar conexión a la base de datos
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Configurar SQLite para Flutter
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Obtener directorio de documentos
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.db'));

    return NativeDatabase.createInBackground(file);
  });
}
