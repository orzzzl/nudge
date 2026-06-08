# 34 — check-in 回写更新日志（auto，不改状态）

- **Status:** READY
- **Owner:** Codex
- **Blocked by:** 24 ✅ (PR #44), 32 ✅ (PR #43)
- **Allowed new deps:** none

## Goal
一格到点 check-in 后，若这格关联了某条 todo（`plans.todoId`），就往那条 todo 的更新日志自动记一笔进展。**绝不自动改 todo 状态**（大任务做一格 ≠ 完成）。

## Scope
- in:
  - `lib/features/chat/chat_controller.dart` 的 `checkIn(...)`：拿到刚 check-in 的 plan，如果它有 `todoId`，调用 `todoRepository.addLog(todoId, text, kind: auto)`。
  - 文案（默认**带结果**，见 [DESIGN.md](DESIGN.md) §5）：如「做了 1h · ✅ 搞定 / 🍃 做了点 / 😴 没动」——结果映射 `PlanStatus.done/partial/missed`；时长来自 plan 的 `durationSec`。文案走 i18n（en/zh），结果 emoji 可内嵌。
  - chat_controller 需要能读 `todoRepository`（provider）。读 `plan.todoId`（task 32 已让 `Plan` 带该字段）。
  - **防御**：若 `plan.todoId` 指向的 todo 已不存在，**no-op**、不抛（采纳 Codex 审核）——可在 `addLog` 内部或回写前判断。
  - 不触碰 todo.status。
  - i18n：auto 日志文案模板（带时长与结果）。
- out: 日志展示（task 31）；状态改动（**禁止**）。

## Acceptance criteria
- [ ] 单测：check-in 一个带 `todoId` 的 plan → `todoRepository.addLog(kind: auto)` 被调，文案含时长 + 对应结果；todo.status **未**被调用更新。
- [ ] check-in 一个无 `todoId` 的 plan → 不写 log（回归现有 check-in 行为）。
- [ ] check-in 一个 `todoId` 指向已不存在 todo 的 plan → no-op、不抛。
- [ ] 无硬编码中文；analyze/format/test 干净。

## Notes / hints
- 现有 check-in 流程见 `chat_controller.dart` 的 `checkIn(PlanStatus)`；plan 的 `todoId` 由 task 32 落库，这里读出来用。
- 时长展示（1h / 30min）可复用 duration 格式化逻辑（若无则抽一个小函数 + 测试）。
