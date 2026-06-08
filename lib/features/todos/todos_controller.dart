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

/// A single todo by id, for the detail route (fleshed out in task 28).
final todoByIdProvider = FutureProvider.autoDispose.family<Todo?, int>((
  ref,
  id,
) {
  return ref.watch(todoRepositoryProvider).getTodoById(id);
});
