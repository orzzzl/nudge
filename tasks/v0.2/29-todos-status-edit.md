# 29 — 详情：状态编辑（5 态面板）

- **Status:** READY
- **Owner:** Codex
- **Blocked by:** 28
- **Allowed new deps:** none

## Goal
详情页点状态 chip `⌄` 弹底部面板（设计稿④），手动改 5 态之一。**状态只能在这里手动改**，别处（尤其 check-in）不得改它。

## Scope
- in:
  - 点 meta 的状态 chip → 底部 sheet，列「未开始 / 进行中 / 暂停 / 完成 / 遗弃」，当前项高亮 ✓，选中 → `updateTodo(status:)` 并关闭。
  - 各态图标/配色对齐设计稿（未开始空心 / 进行中▶绿 / 暂停⏸橙 / 完成✓绿 / 遗弃✕灰）。
  - 改状态后：完成/遗弃在列表会落入「归档」（由 task 26 的分组自动处理，本 task 不重复实现分组）。
  - i18n：状态名 + 面板标题（复用 26 已加的状态名 key）。
- out: 优先级/截止（30）；任何自动改状态的逻辑（**明确禁止**）。

## Acceptance criteria
- [ ] widget test：开面板、当前态高亮、选另一态 → `updateTodo(status:)` 被调且面板关闭。
- [ ] 无硬编码中文；analyze/format/test 干净。

## Notes / hints
- 底部 sheet 用 `showModalBottomSheet`，圆角 + handle，风格见设计稿④与 `cute_palette`。
