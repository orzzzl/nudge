import 'todo.dart';

abstract class TodoRepository {
  Stream<List<Todo>> watchTodos();

  Future<Todo?> getTodoById(int id);

  Future<Todo> createTodo({
    required String title,
    TodoPriority priority = TodoPriority.p2,
    DateTime? dueDate,
  });

  Future<void> updateTodo({
    required int id,
    String? title,
    TodoStatus? status,
    TodoPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? note,
    bool clearNote = false,
  });

  Future<void> deleteTodo(int id);

  Stream<List<TodoLog>> watchLogs(int todoId);

  Future<void> addLog({
    required int todoId,
    required String text,
    required TodoLogKind kind,
  });
}
