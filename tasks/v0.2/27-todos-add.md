# 27 — 添加 todo（「＋ 还想做点什么」入口）

- **Status:** BLOCKED
- **Owner:** Codex
- **Blocked by:** 26
- **Allowed new deps:** none

## Goal
清单页底部常驻的「＋ 还想做点什么…」入口，输入标题即可新建一条 todo。

## Scope
- in:
  - 清单页底部固定一个 add 输入条（设计稿①底部），点开后输入标题 → `todoRepository.createTodo(title:…)`（默认 `status=notStarted, priority=p2, dueDate=null`），新建项出现在「在做 · 想做」组顶部/对应排序位。
  - 空标题不创建（轻提示，仿 `plan_composer.dart` 的 `composerNeedTask` snackbar 思路）。
  - 优先级/截止/备注**不在这里设**——建完进详情再改（保持添加极简）。
  - i18n：add 占位文案、空标题提示（en/zh）。
- out: 详情编辑（28+）。

## Acceptance criteria
- [ ] widget test：输入标题点确认 → 列表多一条；空标题不创建并提示。
- [ ] 无硬编码中文；analyze/format/test 干净。

## Notes / hints
- 复用现有输入风格（`plan_composer.dart` 的 cream field + candy 按钮）。
- 交互形态（底部内联展开 vs 轻量弹层）实现者择简，PR 里说明。
