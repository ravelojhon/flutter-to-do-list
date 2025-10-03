import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// Entidad Task del dominio
@freezed
class Task with _$Task {
  const factory Task({
    int? id,
    required String title,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Task;

  const Task._();

  /// Factory constructor para crear una Task desde JSON
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  /// Método para convertir Task a JSON
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  /// Verifica si la tarea está vencida (si tiene fecha de actualización)
  bool get isUpdated => updatedAt != null;

  /// Obtiene el estado de la tarea como string
  String get statusText => isCompleted ? 'Completada' : 'Pendiente';

  /// Crea una copia de la tarea marcándola como completada
  Task markAsCompleted() {
    return copyWith(isCompleted: true, updatedAt: DateTime.now());
  }

  /// Crea una copia de la tarea marcándola como pendiente
  Task markAsPending() {
    return copyWith(isCompleted: false, updatedAt: DateTime.now());
  }

  /// Crea una copia de la tarea actualizando el título
  Task updateTitle(String newTitle) {
    return copyWith(title: newTitle, updatedAt: DateTime.now());
  }
}
