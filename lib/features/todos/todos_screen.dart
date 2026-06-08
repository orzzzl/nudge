import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/l10n/generated/app_localizations.dart';

import '../../app/cute_palette.dart';
import '../../domain/todo.dart';
import 'todos_controller.dart';
import 'widgets/todo_list_item.dart';

/// The todo list tab: three grouped sections — active, permanent, archived
/// (mockup ①). Tapping a row opens its detail (task 28). The "+ new" entry
/// lands in task 27.
class TodosScreen extends ConsumerWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groupsAsync = ref.watch(todoGroupsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: groupsAsync.when(
          data: (groups) =>
              groups.isEmpty ? const _EmptyState() : _TodoList(groups: groups),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Text(
              l10n.todosLoadError,
              style: const TextStyle(color: CuteColors.textMuted2),
            ),
          ),
        ),
      ),
    );
  }
}

class _TodoList extends StatelessWidget {
  const _TodoList({required this.groups});

  final TodoGroups groups;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (groups.active.isNotEmpty)
          _Section(
            title: l10n.todosSectionActive,
            count: groups.active.length,
            todos: groups.active,
          ),
        if (groups.permanent.isNotEmpty)
          _Section(
            title: '♾️ ${l10n.todosSectionPermanent}',
            count: groups.permanent.length,
            todos: groups.permanent,
          ),
        if (groups.archived.isNotEmpty)
          _Section(title: l10n.todosSectionArchived, todos: groups.archived),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.todos, this.count});

  final String title;
  final int? count;
  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 6, 2, 7),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: CuteColors.textMuted2,
                ),
              ),
              const Spacer(),
              if (count != null)
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: CuteColors.textFaint,
                  ),
                ),
            ],
          ),
        ),
        for (final todo in todos)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TodoListItem(
              todo: todo,
              onTap: () => context.push('/todos/${todo.id}'),
            ),
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📋', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 16),
            Text(
              l10n.todosEmptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CuteColors.textBrown,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.todosEmptyBody,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CuteColors.textMuted2,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
