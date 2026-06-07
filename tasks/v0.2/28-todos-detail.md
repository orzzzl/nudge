# 28 — 清单详情页骨架（标题 + 备注 + meta 行展示）

- **Status:** BLOCKED
- **Owner:** Codex
- **Blocked by:** 24, 26
- **Allowed new deps:** none

## Goal
点列表项进入的详情页（设计稿②）骨架：标题、标题下一行 meta（状态/优先级/截止**只读展示**，编辑在 29/30）、备注编辑、底部按钮位。更新日志在 task 31。

## Scope
- in:
  - 路由：`GoRoute(path: '/todos/:id', …)` 或在 todos branch 下嵌套；从列表项点击进入。
  - `lib/features/todos/todo_detail_screen.dart`：
    - 顶部返回 + 「⋯」（更多：先放"删除" → `deleteTodo` + 返回）。
    - 大标题 `#seq 标题`，标题可编辑（失焦/提交 → `updateTodo(title:)`）。
    - 标题下**一行** meta：状态 chip、`P0/P1/P2` chip、`📅 截止` chip（**本 task 只读展示**，带 `⌄` 暗示可编辑；点击的编辑面板由 29/30 接）。
    - 「具体内容」备注：多行编辑 → `updateTodo(note:/clearNote)`。
    - 底部「▶ 开始这一格」按钮（本 task 先占位/禁用，真正跳转在 task 33）+「⋯」。
  - i18n：各 label（en/zh）。
- out: 状态/优先级/截止的**编辑**（29/30）；更新日志（31）；开始这一格跳转（33）。

## Acceptance criteria
- [ ] widget test：进入详情显示标题/序号/meta/备注；改标题、改备注持久化（mock repo 收到 update）；删除返回列表。
- [ ] meta 三个 chip 的颜色/文案正确（状态/优先级/截止），逾期截止标红。
- [ ] 无硬编码中文；analyze/format/test 干净。

## Notes / hints
- meta 一行紧凑、可换行（设计稿②）。配色见 `cute_palette`。
- 详情数据来源：`todoRepository.getTodoById` 或 watch 单条（实现者择一，建议 watch 以便编辑后即时刷新）。
