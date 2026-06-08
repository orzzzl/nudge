import 'package:flutter_test/flutter_test.dart';
import 'package:nudge/domain/todo.dart';

void main() {
  group('Todo', () {
    test('copyWith updates one field and can clear nullable fields', () {
      final todo = _todo();

      expect(todo.copyWith(title: 'Updated title').title, 'Updated title');
      expect(todo.copyWith(dueDate: null).dueDate, isNull);
      expect(todo.copyWith(note: null).note, isNull);
      expect(todo.copyWith(id: null).id, isNull);
      expect(todo.copyWith(), todo);
    });

    test('supports value equality and hashCode', () {
      final todo = _todo();
      final sameTodo = _todo();
      final differentTodo = _todo().copyWith(seq: 2);

      expect(todo, sameTodo);
      expect(todo.hashCode, sameTodo.hashCode);
      expect(todo, isNot(differentTodo));
    });
  });

  group('TodoLog', () {
    test('copyWith updates one field and can clear id', () {
      final log = _todoLog();

      expect(log.copyWith(text: 'Updated log').text, 'Updated log');
      expect(log.copyWith(kind: TodoLogKind.auto).kind, TodoLogKind.auto);
      expect(log.copyWith(id: null).id, isNull);
      expect(log.copyWith(), log);
    });

    test('supports value equality and hashCode', () {
      final log = _todoLog();
      final sameLog = _todoLog();
      final differentLog = _todoLog().copyWith(todoId: 2);

      expect(log, sameLog);
      expect(log.hashCode, sameLog.hashCode);
      expect(log, isNot(differentLog));
    });
  });
}

Todo _todo() {
  final createdAt = DateTime(2026, 6, 1, 9);

  return Todo(
    id: 1,
    seq: 1,
    title: 'Write weekly report',
    status: TodoStatus.notStarted,
    priority: TodoPriority.p2,
    dueDate: DateTime(2026, 6, 2),
    note: 'Draft the outline',
    createdAt: createdAt,
    updatedAt: createdAt.add(const Duration(minutes: 5)),
  );
}

TodoLog _todoLog() {
  return TodoLog(
    id: 1,
    todoId: 1,
    text: 'Drafted the outline',
    kind: TodoLogKind.manual,
    createdAt: DateTime(2026, 6, 1, 10),
  );
}
