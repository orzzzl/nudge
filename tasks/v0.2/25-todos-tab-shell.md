# 25 — 接入第三个「清单」tab（路由 + 导航 + 占位页）

- **Status:** IN PROGRESS
- **Owner:** Claude
- **Blocked by:** —（用占位页，不依赖数据层）
- **Allowed new deps:** none

## Goal
把底部导航从 2 个 tab 变 3 个：**聊天 / 清单 / 乖乖图**，「清单」插在中间，路由通、能切换，先显示一个占位/空状态页。

## Scope
- in:
  - `lib/app/app_router.dart`：在 `StatefulShellRoute.indexedStack.branches` 里 chat 与 stats **之间**插入第 3 个 `StatefulShellBranch`，`GoRoute(path: '/todos', builder: => const TodosScreen())`。
  - `lib/app/navigation_shell.dart`：`NavigationBar` 在 chat 与 stats 之间插入第 3 个 `NavigationDestination`（图标用 `Icons.checklist`/`checklist_outlined` 或 `Icons.list_alt`，label `localizations.todosTabLabel`）。注意 `currentIndex`/`goBranch` 索引随之变（chat=0, todos=1, stats=2）。
  - `lib/features/todos/todos_screen.dart`：占位 `TodosScreen`（空状态文案 + 团团语气，复用 `cute_palette`），后续 task 26 填充。
  - i18n：`todosTabLabel`（en/zh）+ 占位空状态文案 key。
- out: 真实列表、数据（task 26）。

## Acceptance criteria
- [ ] widget test：底部有 3 个 tab，点「清单」切到 `TodosScreen`，再点回 chat/stats 正常（branch 状态保持）。
- [ ] 现有 chat/stats 的 tab 切换测试仍过（索引变更后修正）。
- [ ] 无硬编码中文；`flutter analyze`/`format`/`test` 干净。

## Notes / hints
- 现有导航见 `navigation_shell.dart` 的 `NavigationBar` 与 `_onDestinationSelected`；路由见 `app_router.dart`。
- 底部顺序以设计稿 tabbar 为准：💬聊天 / 📋清单 / 📊乖乖图。
