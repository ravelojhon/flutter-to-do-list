import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';

/// Entidad Todo del dominio
@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    String? description,
    required bool isCompleted,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    int? priority,
    String? category,
    List<String>? tags,
  }) = _Todo;

  const Todo._();

  /// Verifica si la tarea está vencida
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Verifica si la tarea es de alta prioridad
  bool get isHighPriority => priority == 3;

  /// Verifica si la tarea es de prioridad media
  bool get isMediumPriority => priority == 2;

  /// Verifica si la tarea es de baja prioridad
  bool get isLowPriority => priority == 1;

  /// Obtiene el estado de la tarea como string
  String get statusText {
    if (isCompleted) return 'Completada';
    if (isOverdue) return 'Vencida';
    return 'Pendiente';
  }
}

/// Enum para prioridades
enum TodoPriority {
  low(1, 'Baja'),
  medium(2, 'Media'),
  high(3, 'Alta');

  const TodoPriority(this.value, this.label);
  final int value;
  final String label;
}

/// Enum para categorías
enum TodoCategory {
  personal('Personal'),
  work('Trabajo'),
  shopping('Compras'),
  health('Salud'),
  education('Educación'),
  other('Otro');

  const TodoCategory(this.label);
  final String label;
}
