import 'package:drift/drift.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/todo.dart';

part 'todo_model.freezed.dart';

/// Modelo de datos para Todo (Drift Table)
class Todos extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get priority => integer().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get tags => text().nullable()(); // JSON string

  @override
  Set<Column> get primaryKey => {id};
}

/// Modelo de datos para Todo
@freezed
class TodoModel with _$TodoModel {
  const factory TodoModel({
    required String id,
    required String title,
    String? description,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    int? priority,
    String? category,
    List<String>? tags,
  }) = _TodoModel;

  const TodoModel._();

  /// Convierte de entidad a modelo
  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      isCompleted: todo.isCompleted,
      createdAt: todo.createdAt,
      updatedAt: todo.updatedAt,
      dueDate: todo.dueDate,
      priority: todo.priority,
      category: todo.category,
      tags: todo.tags,
    );
  }

  /// Convierte de modelo a entidad
  Todo toEntity() {
    return Todo(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      dueDate: dueDate,
      priority: priority,
      category: category,
      tags: tags,
    );
  }

  /// Convierte de Map a modelo
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      priority: map['priority'] as int?,
      category: map['category'] as String?,
      tags: map['tags'] != null ? List<String>.from(map['tags'] as List) : null,
    );
  }

  /// Convierte de modelo a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'category': category,
      'tags': tags,
    };
  }
}
