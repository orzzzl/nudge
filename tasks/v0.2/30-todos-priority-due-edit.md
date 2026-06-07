# 30 — 详情：优先级 + 截止日期编辑

- **Status:** BLOCKED
- **Owner:** Codex
- **Blocked by:** 28
- **Allowed new deps:** none

## Goal
详情页 meta 行里另两个可编辑项：优先级（P0/P1/P2）和预期完成日期（含快捷 + 清除）。

## Scope
- in:
  - **优先级**：点 `P0 ⌄` → 小面板/弹层选 `P0/P1/P2`（红/橙/绿），选中 → `updateTodo(priority:)`。
  - **截止日期**：点 `📅 ⌄` → 选择面板：快捷「今天 / 明天 / 本周末 / 清除」+「选日期」(`showDatePicker`)，选中 → `updateTodo(dueDate:/clearDueDate)`。仅存日期（当天 00:00 本地）。
  - meta chip 文案随之刷新（截止显示相对词「明天」「逾期 N 天」「无期限」等，逾期标红）。
  - i18n：优先级名、截止快捷词、相对日期文案（en/zh）。
- out: 状态（29）。

## Acceptance criteria
- [ ] widget test：改优先级 → `updateTodo(priority:)`；选「明天」→ `updateTodo(dueDate:)` 为明天；「清除」→ `clearDueDate`；逾期日期 meta 标红。
- [ ] 相对日期文案的边界（今天/明天/逾期/无期限）有单测。
- [ ] 无硬编码中文；analyze/format/test 干净。

## Notes / hints
- `showDatePicker` 是 Flutter 自带，无需新依赖；主题用现有 app theme。
- 相对日期可抽一个纯函数（输入 dueDate + now → 文案 key + 是否逾期），便于测试与 i18n。
