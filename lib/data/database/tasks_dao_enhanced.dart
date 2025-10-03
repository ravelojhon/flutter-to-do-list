import 'package:drift/drift.dart';
import 'app_database.dart';
import '../models/task_model.dart';
import '../../domain/entities/task.dart';

part 'tasks_dao_enhanced.g.dart';

/// DAO mejorado que usa TaskModel para conversiones
@DriftAccessor(tables: [Tasks])
class TasksDaoEnhanced extends DatabaseAccessor<AppDatabase>
    with _$TasksDaoMixin {
  TasksDaoEnhanced(AppDatabase db) : super(db);

  /// Obtener todas las tareas como TaskModel
  Future<List<TaskModel>> getAllTaskModels() async {
    final driftTasks = await select(tasks).get();
    return driftTasks.map((task) => TaskModel.fromDriftRow(task)).toList();
  }

  /// Obtener todas las tareas como entidades Task
  Future<List<Task>> getAllTasksAsEntities() async {
    final taskModels = await getAllTaskModels();
    return taskModels.map((model) => model.toEntity()).toList();
  }

  /// Obtener tarea por ID como TaskModel
  Future<TaskModel?> getTaskModelById(int id) async {
    final driftTask = await (select(
      tasks,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return driftTask != null ? TaskModel.fromDriftRow(driftTask) : null;
  }

  /// Obtener tarea por ID como entidad Task
  Future<Task?> getTaskEntityById(int id) async {
    final taskModel = await getTaskModelById(id);
    return taskModel?.toEntity();
  }

  /// Insertar entidad Task
  Future<int> insertTaskEntity(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    final companion = taskModel.toCompanion();
    return await into(tasks).insert(companion);
  }

  /// Insertar TaskModel
  Future<int> insertTaskModel(TaskModel taskModel) async {
    final companion = taskModel.toCompanion();
    return await into(tasks).insert(companion);
  }

  /// Actualizar entidad Task
  Future<bool> updateTaskEntity(Task task) async {
    if (task.id == null) return false;

    final taskModel = TaskModel.fromEntity(task);
    final companion = taskModel.toCompanion();

    final result = await (update(
      tasks,
    )..where((tbl) => tbl.id.equals(task.id!))).write(companion);

    return result > 0;
  }

  /// Actualizar TaskModel
  Future<bool> updateTaskModel(TaskModel taskModel) async {
    final companion = taskModel.toCompanion();

    final result = await (update(
      tasks,
    )..where((tbl) => tbl.id.equals(taskModel.id))).write(companion);

    return result > 0;
  }

  /// Obtener tareas por estado como entidades
  Future<List<Task>> getTasksByStatusAsEntities(bool isCompleted) async {
    final driftTasks = await (select(
      tasks,
    )..where((tbl) => tbl.isCompleted.equals(isCompleted))).get();

    return driftTasks
        .map((task) => TaskModel.fromDriftRow(task).toEntity())
        .toList();
  }

  /// Buscar tareas como entidades
  Future<List<Task>> searchTasksAsEntities(String query) async {
    final driftTasks = await (select(
      tasks,
    )..where((tbl) => tbl.title.contains(query))).get();

    return driftTasks
        .map((task) => TaskModel.fromDriftRow(task).toEntity())
        .toList();
  }

  /// Obtener estadísticas usando TaskModel
  Future<TaskStats> getTaskStatsFromModels() async {
    final taskModels = await getAllTaskModels();
    final total = taskModels.length;
    final completed = taskModels.where((model) => model.isCompleted).length;
    final pending = total - completed;

    return TaskStats(total: total, completed: completed, pending: pending);
  }

  /// Marcar tarea como completada usando entidad
  Future<bool> markTaskAsCompleted(int id) async {
    final taskModel = await getTaskModelById(id);
    if (taskModel == null) return false;

    final updatedModel = taskModel.copyWith(
      isCompleted: true,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    return await updateTaskModel(updatedModel);
  }

  /// Marcar tarea como pendiente usando entidad
  Future<bool> markTaskAsPending(int id) async {
    final taskModel = await getTaskModelById(id);
    if (taskModel == null) return false;

    final updatedModel = taskModel.copyWith(
      isCompleted: false,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    return await updateTaskModel(updatedModel);
  }

  /// Actualizar título de tarea
  Future<bool> updateTaskTitle(int id, String newTitle) async {
    final taskModel = await getTaskModelById(id);
    if (taskModel == null) return false;

    final updatedModel = taskModel.copyWith(
      title: newTitle,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    return await updateTaskModel(updatedModel);
  }

  /// Obtener tareas recientes (últimas N tareas)
  Future<List<Task>> getRecentTasksAsEntities(int limit) async {
    final driftTasks =
        await (select(tasks)
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
              ..limit(limit))
            .get();

    return driftTasks
        .map((task) => TaskModel.fromDriftRow(task).toEntity())
        .toList();
  }

  /// Obtener tareas por rango de fechas
  Future<List<Task>> getTasksByDateRangeAsEntities(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;

    final driftTasks =
        await (select(tasks)..where(
              (tbl) =>
                  tbl.createdAt.isBiggerOrEqualValue(startTimestamp) &
                  tbl.createdAt.isSmallerOrEqualValue(endTimestamp),
            ))
            .get();

    return driftTasks
        .map((task) => TaskModel.fromDriftRow(task).toEntity())
        .toList();
  }
}
