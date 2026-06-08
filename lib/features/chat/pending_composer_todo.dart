import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A todo handed to the chat composer so the next plan starts "from the list".
/// `seq`/`title` drive the removable chip; `todoId` is carried onto the created
/// plan (`plans.todoId`) for check-in writeback.
typedef PendingComposerTodo = ({int todoId, int seq, String title});

/// A one-shot inbox: the list/detail screen (task 33) calls [set] and switches
/// to the chat tab; the composer drains it into local state on the next build
/// and calls [clear]. Null = plain manual input.
class PendingComposerTodoController extends Notifier<PendingComposerTodo?> {
  @override
  PendingComposerTodo? build() => null;

  void set(PendingComposerTodo todo) => state = todo;

  void clear() => state = null;
}

final pendingComposerTodoProvider =
    NotifierProvider<PendingComposerTodoController, PendingComposerTodo?>(
      PendingComposerTodoController.new,
    );
