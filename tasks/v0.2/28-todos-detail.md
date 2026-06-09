# 28 — 清单详情页（默认只读 + 「⋯」菜单）

- **Status:** DONE (PR #47)
- **Owner:** Claude
- **Blocked by:** 24 ✅, 26 ✅ (PR #45), 27 ✅ (PR #46)

> **Note (post-#45/#46):** task 26 already added the `/todos/:id` route + a `TodoDetailScreen`
> placeholder + `todoByIdProvider`; flesh out that screen (don't re-add the route). Task 27 shipped
> the reusable `TodoEditScreen({Todo? initial})` — the "⋯ → 编辑" action pushes it with the current
> todo as `initial`. `createTodo` now also takes `note`.
- **Allowed new deps:** none

## Goal
点列表项进入的详情页（设计稿②）：**默认只读**展示标题/meta/备注/更新日志 + 底部「▶ 开始这一格」+「⋯」。**编辑靠「⋯」→「编辑」进入 task 27 的编辑页**（预填当前值）。状态改是例外——详情页保留一键改状态快捷。

## Scope
- in:
  - 路由：`GoRoute(path: '/todos/:id', …)`；从列表项进入。
  - `lib/features/todos/todo_detail_screen.dart`（**只读为主**）：
    - 顶栏：返回（**不再放「⋯」**，避免和底部冗余）。
    - 大标题 `#seq 标题`（只读）。
    - 标题下一行 meta：状态 chip / 优先级 chip / 截止 chip（**只读展示**；逾期截止标红；`permanent` 项不显示状态与截止）。
    - 「具体内容」备注（**只读**）。更新日志见 task 31。
    - 底部：「▶ 开始这一格」（跳转在 task 33）+ 「**⋯**」。
  - **「⋯」底部菜单**：**编辑**（→ push task 27 的编辑页、预填当前 todo，保存后返回只读）/ **复制为新清单项**（基于当前 标题+优先级+备注 `createTodo` 一条新的，截止/状态/日志不带）/ **删除**（红、二次确认 → `todoRepository.deleteTodo`）。**系统自带永久项（吃饭/睡觉）隐藏「删除」**。
  - **状态快捷**：点 meta 的状态 chip → task 29 的状态面板（高频，不必进编辑页）。`permanent` 项无此入口。
  - i18n：各 label、菜单项、删除确认文案（en/zh）。
- out: 编辑表单本体（27）；状态面板（29）；更新日志（31）；开始跳转（33）。

## Acceptance criteria
- [ ] widget test：进入详情**只读**显示标题/序号/meta/备注；逾期截止标红；`permanent` 项不显示状态/截止。
- [ ] 「⋯」→「编辑」push 编辑页且预填；「复制」→ `createTodo` 被调；「删除」→ 二次确认后 `deleteTodo` + 返回列表。
- [ ] 自带永久项的「⋯」**无「删除」**。
- [ ] 无硬编码中文；analyze/format/test 干净。

## Notes / hints
- 详情数据：watch 单条（编辑/状态改后即时刷新）。
- 「⋯」用 `showModalBottomSheet`；删除确认用 `AlertDialog`。配色 `cute_palette`，对照稿②。
