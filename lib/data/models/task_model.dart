import 'package:drift/drift.dart';
import '../../domain/entities/task.dart';
import '../database/app_database.dart';

/// Modelo de datos para Task (representa una fila de Drift)
class TaskModel extends DataClass implements Insertable<TaskModel> {
  final int id;
  final String title;
  final bool isCompleted;
  final int createdAt;
  final int? updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    this.updatedAt,
  });

  /// Constructor desde fila de Drift
  factory TaskModel.fromDriftRow(Task driftTask) {
    return TaskModel(
      id: driftTask.id,
      title: driftTask.title,
      isCompleted: driftTask.isCompleted,
      createdAt: driftTask.createdAt,
      updatedAt: driftTask.updatedAt,
    );
  }

  /// Convierte de entidad Task a TaskModel
  factory TaskModel.fromEntity(Task entity) {
    return TaskModel(
      id:
          entity.id ??
          0, // Si no tiene ID, usar 0 (se generará automáticamente)
      title: entity.title,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt?.millisecondsSinceEpoch,
    );
  }

  /// Convierte TaskModel a entidad Task
  Task toEntity() {
    return Task(
      id: id == 0 ? null : id, // Si ID es 0, devolver null (no persistido)
      title: title,
      isCompleted: isCompleted,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: updatedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAt!)
          : null,
    );
  }

  /// Convierte TaskModel a TasksCompanion para insertar
  TasksCompanion toCompanion() {
    return TasksCompanion(
      id: id == 0 ? const Value.absent() : Value(id),
      title: Value(title),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
      updatedAt: updatedAt != null ? Value(updatedAt!) : const Value.absent(),
    );
  }

  /// Crea una copia del TaskModel con campos modificados
  TaskModel copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    int? createdAt,
    int? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte TaskModel a Map para serialización
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Crea TaskModel desde Map
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int?,
    );
  }

  /// Verifica si la tarea fue actualizada
  bool get isUpdated => updatedAt != null;

  /// Obtiene la fecha de creación como DateTime
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);

  /// Obtiene la fecha de actualización como DateTime
  DateTime? get updatedAtDateTime => updatedAt != null
      ? DateTime.fromMillisecondsSinceEpoch(updatedAt!)
      : null;

  /// Obtiene el estado como string
  String get statusText => isCompleted ? 'Completada' : 'Pendiente';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel &&
        other.id == id &&
        other.title == title &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        isCompleted.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, isCompleted: $isCompleted, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    ).toColumns(nullToAbsent);
  }
}
