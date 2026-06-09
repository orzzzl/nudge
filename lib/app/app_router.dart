import 'package:go_router/go_router.dart';

import '../features/chat/chat_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stats/stats_screen.dart';
import '../features/todos/todo_detail_screen.dart';
import '../features/todos/todo_edit_screen.dart';
import '../features/todos/todos_screen.dart';
import '../domain/todo.dart';
import 'navigation_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/chat',
  routes: [
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/todos/new',
      builder: (context, state) => const TodoEditScreen(),
    ),
    GoRoute(
      path: '/todos/:id/edit',
      builder: (context, state) {
        final todo = state.extra;
        if (todo is Todo) {
          return TodoEditScreen(initial: todo);
        }
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return TodoEditLoader(todoId: id);
      },
    ),
    GoRoute(
      path: '/todos/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return TodoDetailScreen(todoId: id ?? 0);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NudgeNavigationShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/todos',
              builder: (context, state) => const TodosScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
