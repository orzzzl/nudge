# 27 — 新建清单项（「＋」→ 全屏新建编辑页）

- **Status:** DONE (PR #46)
- **Owner:** Claude
- **Blocked by:** 26 ✅ (PR #45)

> **Landed for task 28:** reusable `lib/features/todos/todo_edit_screen.dart` —
> `TodoEditScreen({Todo? initial})`. `initial == null` = create; pass a todo for edit
> (prefills, saves via `updateTodo`). 28's "⋯ → 编辑" just does
> `context.push` to it / shows it with `initial`. `createTodo` gained a `String? note` param.
- **Allowed new deps:** none

## Goal
清单页底部「＋ 新建清单项」按钮 → **跳转到一个全屏新建编辑页**（不是对话框），填标题/重要程度/截止/备注后创建，**创建后回清单列表**。设计稿①底部按钮 + 稿①b 编辑页。

## Scope
- in:
  - 清单页底部一个**绿色「＋ 新建清单项」按钮**（替换之前的内联输入条），点击 → `push` 全屏新建编辑页。
  - **新建编辑页**（稿①b）：标题（必填）+ 重要程度（`P0/P1/P2/永久`，默认 `P2`）+ 预期完成（`今天/明天/选日期`；**选「永久」则隐藏/禁用截止**）+ 大备注框（可选，撑满剩余屏幕）+ 「创建」按钮。
  - 「创建」→ `todoRepository.createTodo(title, priority, dueDate?, note?)` → **返回清单列表**。空标题不创建（轻提示，仿 `plan_composer.dart` 的 `composerNeedTask`）。选「永久」时 `dueDate` 存 `null`。
  - **与 task 28「编辑已有项」复用同一套表单**：建议本 task 产出可复用的 `TodoEditScreen/Form`（新建态 = 空白；编辑态由 28 传入预填值）。
  - i18n：标题/各 label/hint/创建/空标题提示（en/zh）。
- out: 详情页与「编辑」入口（28）；列表分组/排序（26）。

## Acceptance criteria
- [ ] widget test：点「＋」进编辑页；填标题 + 选优先级/截止/备注 → 创建 → 回列表且列表多一条；空标题不创建并提示。
- [ ] 选「永久」→ 截止不可选、`createTodo` 的 `dueDate` 为 `null`。
- [ ] 无硬编码中文；analyze/format/test 干净。

## Notes / hints
- 全屏页用 `GoRoute`（如 `/todos/new`）或 push 一个 `MaterialPageRoute`，复用 `cute_palette` + candy 原语；视觉对照稿①b。
- 表单组件设计成"新建/编辑"两态复用，给 28 省一遍。
