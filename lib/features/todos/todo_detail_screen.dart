import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/cute_palette.dart';
import 'todos_controller.dart';

/// Placeholder todo detail (mockup ②). Task 26 only wires the route + title so
/// tapping a list row opens here; the read-only meta, update log, status panel,
/// and the "start this block" action land in tasks 28-31.
class TodoDetailScreen extends ConsumerWidget {
  const TodoDetailScreen({required this.todoId, super.key});

  final int todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoAsync = ref.watch(todoByIdProvider(todoId));

    return Scaffold(
      key: const Key('todoDetailScreen'),
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: todoAsync.maybeWhen(
          data: (todo) => todo == null
              ? const SizedBox.shrink()
              : Text(
                  '#${todo.seq}  ${todo.title}',
                  style: const TextStyle(
                    color: CuteColors.matcha,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
          orElse: () => const SizedBox.shrink(),
        ),
      ),
      body: const SizedBox.shrink(),
    );
  }
}
