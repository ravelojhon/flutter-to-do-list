import 'task_model.dart';
import '../../domain/entities/task.dart';
import '../database/app_database.dart';

/// Ejemplos de uso del TaskModel
class TaskModelExample {
  /// Ejemplo 1: Crear TaskModel desde entidad Task
  static void createFromEntity() {
    print('=== Crear TaskModel desde entidad Task ===');

    // Crear entidad Task
    final task = Task(
      id: 1,
      title: 'Aprender Flutter',
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    print('Entidad Task: ${task.toJson()}');

    // Convertir a TaskModel
    final taskModel = TaskModel.fromEntity(task);
    print('TaskModel: $taskModel');
    print('Fecha de creación: ${taskModel.createdAtDateTime}');
    print('Estado: ${taskModel.statusText}');
  }

  /// Ejemplo 2: Crear entidad Task desde TaskModel
  static void createEntityFromModel() {
    print('\n=== Crear entidad Task desde TaskModel ===');

    // Crear TaskModel
    final taskModel = TaskModel(
      id: 2,
      title: 'Implementar Drift',
      isCompleted: true,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    print('TaskModel: $taskModel');
    print('¿Fue actualizada? ${taskModel.isUpdated}');

    // Convertir a entidad Task
    final task = taskModel.toEntity();
    print('Entidad Task: ${task.toJson()}');
  }

  /// Ejemplo 3: Operaciones con TasksCompanion
  static void companionOperations() {
    print('\n=== Operaciones con TasksCompanion ===');

    // Crear TaskModel
    final taskModel = TaskModel(
      id: 0, // ID 0 indica que no está persistido
      title: 'Nueva tarea',
      isCompleted: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: null,
    );

    print('TaskModel original: $taskModel');

    // Convertir a TasksCompanion para insertar
    final companion = taskModel.toCompanion();
    print('TasksCompanion: $companion');

    // Crear TaskModel con ID generado
    final persistedModel = taskModel.copyWith(id: 3);
    print('TaskModel persistido: $persistedModel');
  }

  /// Ejemplo 4: Serialización/Deserialización
  static void serializationExample() {
    print('\n=== Serialización/Deserialización ===');

    // Crear TaskModel
    final originalModel = TaskModel(
      id: 4,
      title: 'Tarea serializable',
      isCompleted: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: null,
    );

    print('Modelo original: $originalModel');

    // Convertir a Map
    final map = originalModel.toMap();
    print('Map: $map');

    // Recrear desde Map
    final recreatedModel = TaskModel.fromMap(map);
    print('Modelo recreado: $recreatedModel');
    print('¿Son iguales? ${originalModel == recreatedModel}');
  }

  /// Ejemplo 5: Flujo completo con base de datos
  static Future<void> databaseFlowExample() async {
    print('\n=== Flujo completo con base de datos ===');

    // Inicializar base de datos
    final database = AppDatabase();
    final dao = database.tasksDao;

    try {
      // 1. Crear entidad Task
      final task = Task(
        id: null, // No tiene ID aún
        title: 'Tarea desde entidad',
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      print('Entidad Task creada: ${task.toJson()}');

      // 2. Convertir a TaskModel
      final taskModel = TaskModel.fromEntity(task);
      print('TaskModel: $taskModel');

      // 3. Convertir a TasksCompanion e insertar
      final companion = taskModel.toCompanion();
      final insertedId = await dao.insertTask(companion);
      print('Tarea insertada con ID: $insertedId');

      // 4. Obtener tarea de la base de datos
      final driftTask = await dao.getTaskById(insertedId);
      if (driftTask != null) {
        // 5. Convertir fila de Drift a TaskModel
        final retrievedModel = TaskModel.fromDriftRow(driftTask);
        print('TaskModel desde Drift: $retrievedModel');

        // 6. Convertir a entidad Task
        final retrievedEntity = retrievedModel.toEntity();
        print('Entidad Task final: ${retrievedEntity.toJson()}');

        // 7. Actualizar tarea
        final updatedModel = retrievedModel.copyWith(
          isCompleted: true,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        final updatedEntity = updatedModel.toEntity();
        print('Entidad actualizada: ${updatedEntity.toJson()}');

        // 8. Actualizar en base de datos
        final updatedCompanion = updatedModel.toCompanion();
        await dao.updateTaskById(
          insertedId,
          title: updatedModel.title,
          isCompleted: updatedModel.isCompleted,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(
            updatedModel.updatedAt!,
          ),
        );

        print('Tarea actualizada en base de datos');
      }
    } finally {
      // Cerrar base de datos
      await database.close();
    }
  }

  /// Ejemplo 6: Lista de conversiones
  static void listConversions() {
    print('\n=== Conversiones de listas ===');

    // Lista de entidades Task
    final tasks = [
      Task(
        id: 1,
        title: 'Tarea 1',
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
      Task(
        id: 2,
        title: 'Tarea 2',
        isCompleted: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Task(
        id: 3,
        title: 'Tarea 3',
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
    ];

    print('Entidades Task originales:');
    for (final task in tasks) {
      print('  ${task.toJson()}');
    }

    // Convertir a TaskModels
    final taskModels = tasks.map((task) => TaskModel.fromEntity(task)).toList();
    print('\nTaskModels:');
    for (final model in taskModels) {
      print('  $model');
    }

    // Convertir de vuelta a entidades
    final convertedTasks = taskModels.map((model) => model.toEntity()).toList();
    print('\nEntidades convertidas:');
    for (final task in convertedTasks) {
      print('  ${task.toJson()}');
    }

    // Verificar que son iguales
    bool areEqual = true;
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].toJson().toString() !=
          convertedTasks[i].toJson().toString()) {
        areEqual = false;
        break;
      }
    }
    print('\n¿Las listas son iguales? $areEqual');
  }

  /// Ejecutar todos los ejemplos
  static Future<void> runAllExamples() async {
    createFromEntity();
    createEntityFromModel();
    companionOperations();
    serializationExample();
    await databaseFlowExample();
    listConversions();
  }
}
