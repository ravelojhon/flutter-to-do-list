import 'task.dart';

/// Ejemplo de uso de la clase Task
void taskExample() {
  // Crear una nueva tarea
  final task = Task(
    id: 1,
    title: 'Completar documentación',
    isCompleted: false,
    createdAt: DateTime.now(),
  );

  print('Tarea creada: ${task.toJson()}');

  // Marcar como completada
  final completedTask = task.markAsCompleted();
  print('Tarea completada: ${completedTask.toJson()}');

  // Actualizar título
  final updatedTask = task.updateTitle('Documentación actualizada');
  print('Tarea actualizada: ${updatedTask.toJson()}');

  // Crear desde JSON
  final jsonData = {
    'id': 2,
    'title': 'Revisar código',
    'isCompleted': true,
    'createdAt': DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  final taskFromJson = Task.fromJson(jsonData);
  print('Tarea desde JSON: ${taskFromJson.toJson()}');

  // Verificar estado
  print('¿Está completada? ${taskFromJson.isCompleted}');
  print('¿Fue actualizada? ${taskFromJson.isUpdated}');
  print('Estado: ${taskFromJson.statusText}');
}
