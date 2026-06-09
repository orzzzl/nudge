import 'package:drift/drift.dart' as drift;

import '../../domain/todo.dart';
import '../../domain/todo_repository.dart';
import '../db/app_database.dart' as db;

class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(this._database)
    : _todosDao = _database.todosDao,
      _todoLogsDao = _database.todoLogsDao;

  final db.AppDatabase _database;
  final db.TodosDao _todosDao;
  final db.TodoLogsDao _todoLogsDao;

  @override
  Stream<List<Todo>> watchTodos() {
    return _todosDao.watchTodos().map((rows) {
      final todos = rows.map(_mapRow).toList(growable: false);

      return _sortTodos(todos);
    });
  }

  @override
  Future<Todo?> getTodoById(int id) async {
    final row = await _todosDao.getTodoById(id);

    return row == null ? null : _mapRow(row);
  }

  @override
  Future<Todo> createTodo({
    required String title,
    TodoPriority priority = TodoPriority.p2,
    DateTime? dueDate,
    String? note,
  }) {
    return _database.transaction(() async {
      final seqCandidate = await _todosDao.getNextSeqCandidate();
      final now = DateTime.now();
      final storedDueDate = priority == TodoPriority.permanent
          ? null
          : _dateOnly(dueDate);
      final id = await _todosDao.insertTodo(
        db.TodosCompanion.insert(
          seq: seqCandidate,
          title: title,
          status: drift.Value(TodoStatus.notStarted.name),
          priority: drift.Value(priority.name),
          dueDate: drift.Value(storedDueDate),
          note: drift.Value(note),
          createdAt: now,
          updatedAt: now,
        ),
      );
      final finalSeq = id > seqCandidate ? id : seqCandidate;
      if (finalSeq != seqCandidate) {
        await _todosDao.updateTodoById(
          id: id,
          todo: db.TodosCompanion(seq: drift.Value(finalSeq)),
        );
      }
      final row = await _todosDao.getTodoById(id);

      return _mapRow(row!);
    });
  }

  @override
  Future<void> updateTodo({
    required int id,
    String? title,
    TodoStatus? status,
    TodoPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? note,
    bool clearNote = false,
  }) async {
    final forceClearDueDate =
        clearDueDate || priority == TodoPriority.permanent;
    await _todosDao.updateTodoById(
      id: id,
      todo: db.TodosCompanion(
        title: _optionalValue(title),
        status: _optionalValue(status?.name),
        priority: _optionalValue(priority?.name),
        dueDate: forceClearDueDate
            ? const drift.Value<DateTime?>(null)
            : _optionalValue(_dateOnly(dueDate)),
        note: clearNote
            ? const drift.Value<String?>(null)
            : _optionalValue(note),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteTodo(int id) async {
    await _database.transaction(() async {
      await _todoLogsDao.deleteLogsForTodo(id);
      await _todosDao.clearPlansTodoId(id);
      await _todosDao.deleteTodoById(id);
    });
  }

  @override
  Stream<List<TodoLog>> watchLogs(int todoId) {
    return _todoLogsDao
        .watchLogsForTodo(todoId)
        .map((rows) => rows.map(_mapLog).toList(growable: false));
  }

  @override
  Future<void> addLog({
    required int todoId,
    required String text,
    required TodoLogKind kind,
  }) async {
    await _todoLogsDao.insertLog(
      db.TodoLogsCompanion.insert(
        todoId: todoId,
        entryText: text,
        kind: kind.name,
        createdAt: DateTime.now(),
      ),
    );
  }

  Todo _mapRow(db.TodoRow row) {
    return Todo(
      id: row.id,
      seq: row.seq,
      title: row.title,
      status: _statusFromText(row.status),
      priority: _priorityFromText(row.priority),
      dueDate: row.dueDate,
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  TodoLog _mapLog(db.TodoLogRow row) {
    return TodoLog(
      id: row.id,
      todoId: row.todoId,
      text: row.entryText,
      kind: _logKindFromText(row.kind),
      createdAt: row.createdAt,
    );
  }

  TodoStatus _statusFromText(String status) {
    try {
      return TodoStatus.values.byName(status);
    } on ArgumentError catch (_) {
      throw StateError('Unknown todo status: $status');
    }
  }

  TodoPriority _priorityFromText(String priority) {
    try {
      return TodoPriority.values.byName(priority);
    } on ArgumentError catch (_) {
      throw StateError('Unknown todo priority: $priority');
    }
  }

  TodoLogKind _logKindFromText(String kind) {
    try {
      return TodoLogKind.values.byName(kind);
    } on ArgumentError catch (_) {
      throw StateError('Unknown todo log kind: $kind');
    }
  }

  List<Todo> _sortTodos(List<Todo> todos) {
    return [...todos]..sort(_compareTodos);
  }

  int _compareTodos(Todo a, Todo b) {
    final groupComparison = _groupRank(a).compareTo(_groupRank(b));
    if (groupComparison != 0) {
      return groupComparison;
    }

    return switch (_groupRank(a)) {
      0 => _compareActiveTodos(a, b),
      1 => a.seq.compareTo(b.seq),
      _ => _compareArchivedTodos(a, b),
    };
  }

  int _compareActiveTodos(Todo a, Todo b) {
    final priorityComparison = _priorityRank(
      a.priority,
    ).compareTo(_priorityRank(b.priority));
    if (priorityComparison != 0) {
      return priorityComparison;
    }

    final dueDateComparison = _compareDueDates(a.dueDate, b.dueDate);
    if (dueDateComparison != 0) {
      return dueDateComparison;
    }

    return a.seq.compareTo(b.seq);
  }

  int _compareArchivedTodos(Todo a, Todo b) {
    final updatedAtComparison = b.updatedAt.compareTo(a.updatedAt);
    if (updatedAtComparison != 0) {
      return updatedAtComparison;
    }

    return b.seq.compareTo(a.seq);
  }

  int _groupRank(Todo todo) {
    if (todo.priority == TodoPriority.permanent) {
      return 1;
    }
    if (todo.status == TodoStatus.done || todo.status == TodoStatus.dropped) {
      return 2;
    }

    return 0;
  }

  int _priorityRank(TodoPriority priority) {
    return switch (priority) {
      TodoPriority.p0 => 0,
      TodoPriority.p1 => 1,
      TodoPriority.p2 => 2,
      TodoPriority.permanent => 3,
    };
  }

  int _compareDueDates(DateTime? a, DateTime? b) {
    if (a == null && b == null) {
      return 0;
    }
    if (a == null) {
      return 1;
    }
    if (b == null) {
      return -1;
    }

    return a.compareTo(b);
  }

  DateTime? _dateOnly(DateTime? value) {
    if (value == null) {
      return null;
    }

    return DateTime(value.year, value.month, value.day);
  }

  drift.Value<T> _optionalValue<T>(T? value) {
    return value == null ? const drift.Value.absent() : drift.Value(value);
  }
}
