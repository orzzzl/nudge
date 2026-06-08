enum TodoStatus { notStarted, inProgress, paused, done, dropped }

enum TodoPriority { p0, p1, p2, permanent }

enum TodoLogKind { manual, auto }

class Todo {
  const Todo({
    required this.id,
    required this.seq,
    required this.title,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final int seq;
  final String title;
  final TodoStatus status;
  final TodoPriority priority;
  final DateTime? dueDate;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  Todo copyWith({
    Object? id = _unset,
    int? seq,
    String? title,
    TodoStatus? status,
    TodoPriority? priority,
    Object? dueDate = _unset,
    Object? note = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: identical(id, _unset) ? this.id : id as int?,
      seq: seq ?? this.seq,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: identical(dueDate, _unset) ? this.dueDate : dueDate as DateTime?,
      note: identical(note, _unset) ? this.note : note as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Todo &&
            other.id == id &&
            other.seq == seq &&
            other.title == title &&
            other.status == status &&
            other.priority == priority &&
            other.dueDate == dueDate &&
            other.note == note &&
            other.createdAt == createdAt &&
            other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      seq,
      title,
      status,
      priority,
      dueDate,
      note,
      createdAt,
      updatedAt,
    );
  }
}

class TodoLog {
  const TodoLog({
    required this.id,
    required this.todoId,
    required this.text,
    required this.kind,
    required this.createdAt,
  });

  final int? id;
  final int todoId;
  final String text;
  final TodoLogKind kind;
  final DateTime createdAt;

  TodoLog copyWith({
    Object? id = _unset,
    int? todoId,
    String? text,
    TodoLogKind? kind,
    DateTime? createdAt,
  }) {
    return TodoLog(
      id: identical(id, _unset) ? this.id : id as int?,
      todoId: todoId ?? this.todoId,
      text: text ?? this.text,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TodoLog &&
            other.id == id &&
            other.todoId == todoId &&
            other.text == text &&
            other.kind == kind &&
            other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, todoId, text, kind, createdAt);
  }
}

const Object _unset = Object();
