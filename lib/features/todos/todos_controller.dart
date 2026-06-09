import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/todo.dart';

/// The three display buckets the list renders (mockup ①). The repository hands
/// back an already-sorted flat list (active → permanent → archived, see task 24
/// `watchTodos`); this controller only partitions it, preserving that order.
@immutable
class TodoGroups {
  const TodoGroups({
    required this.active,
    required this.permanent,
    required this.archived,
  });

  final List<Todo> active;
  final List<Todo> permanent;
  final List<Todo> archived;

  bool get isEmpty => active.isEmpty && permanent.isEmpty && archived.isEmpty;
}

/// Partition rule (matches task 24's grouping): permanent priority → permanent
/// group; done/dropped → archived; everything else → active. Permanent is
/// checked first so a permanent todo never lands in archived.
TodoGroups groupTodos(List<Todo> todos) {
  final active = <Todo>[];
  final permanent = <Todo>[];
  final archived = <Todo>[];

  for (final todo in todos) {
    if (todo.priority == TodoPriority.permanent) {
      permanent.add(todo);
    } else if (todo.status == TodoStatus.done ||
        todo.status == TodoStatus.dropped) {
      archived.add(todo);
    } else {
      active.add(todo);
    }
  }

  return TodoGroups(active: active, permanent: permanent, archived: archived);
}

/// Live grouped todos for the list tab.
final todoGroupsProvider = StreamProvider.autoDispose<TodoGroups>((ref) {
  return ref.watch(todoRepositoryProvider).watchTodos().map(groupTodos);
});

/// Live update-log timeline for one todo (chronological, early -> late).
final todoLogsProvider = StreamProvider.autoDispose.family<List<TodoLog>, int>((
  ref,
  todoId,
) {
  return ref.watch(todoRepositoryProvider).watchLogs(todoId);
});

/// A single live todo by id, for the detail route. Derived from [watchTodos] so
/// the detail page refreshes immediately after an edit / status change (task 28
/// requires the detail to be live, not a one-shot fetch). If the list ever grows
/// large, a dedicated `watchTodoById(id)` on the repo would be tidier.
final todoByIdProvider = StreamProvider.autoDispose.family<Todo?, int>((
  ref,
  id,
) {
  return ref.watch(todoRepositoryProvider).watchTodos().map((todos) {
    for (final todo in todos) {
      if (todo.id == id) {
        return todo;
      }
    }
    return null;
  });
});
