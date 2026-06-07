# 31 — 更新日志（时间线 + 手动记一笔）

- **Status:** BLOCKED
- **Owner:** Codex
- **Blocked by:** 24, 28
- **Allowed new deps:** none

## Goal
详情页底部的「更新日志」：时间线**正序**（早在上、新在下）展示该 todo 的所有 log，并能「＋ 记一笔进展」手动加一条。

## Scope
- in:
  - 详情页「更新日志」区：watch `todoRepository.watchLogs(todoId)`，时间线渲染（时间 + 文本，`auto` 那条有视觉区分——橙点 + 小标，见设计稿②）。
  - 「＋ 记一笔进展…」输入 → `addLog(todoId, text, kind: manual)`。
  - 空日志时不显示空时间线（或一句占位）。
  - i18n：区标题、占位、记一笔提示（en/zh）。
- out: `auto` 日志的**写入**（在 task 34 的 check-in 回写）；本 task 只负责展示（含已存在的 auto 条）+ 手动加。

## Acceptance criteria
- [ ] widget test：渲染多条 log 正序；`auto` 条有区分样式；输入文本「＋记一笔」→ `addLog(kind: manual)` 被调，新条出现在底部。
- [ ] 无硬编码中文；analyze/format/test 干净。

## Notes / hints
- 时间线竖线/圆点见设计稿②；用 Column + 自绘点即可，无需新依赖。
- `auto` 文案由 task 34 生成；本 task 只按 `kind` 区分样式。
