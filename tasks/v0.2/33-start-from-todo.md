# 33 —「开始这一格」从清单跳聊天并预填 chip

- **Status:** BLOCKED
- **Owner:** Codex
- **Blocked by:** 28, 32, 25
- **Allowed new deps:** none

## Goal
详情页（和可选的列表项）的「▶ 开始这一格」→ 切到聊天 tab，并让 composer 自动放上该 todo 的 chip（设计稿③）。**不自动改 todo 状态。**

## Scope
- in:
  - 详情页「▶ 开始这一格」：设置 `pendingComposerTodoProvider`（task 32 定义）为 `(todoId, seq, title)`，再切到聊天 branch（`StatefulNavigationShell.goBranch(chatIndex)` 或 `context.go('/chat')`）。
  - 聊天页打开时 composer 读取并消费该 provider → 显示 chip（task 32 的能力）。
  - （可选）列表项右滑/长按或一个快捷入口也能触发同样流程——**可不做，详情页足够**；做了在 PR 说明。
  - 不改 todo 的 status（用户想标"进行中"自己去状态面板改）。
- out: composer chip 渲染（32）；check-in 回写（34）。

## Acceptance criteria
- [ ] widget/integration test：详情点「开始这一格」→ 当前 tab 变聊天 + composer 出现该 todo 的 chip；todo 状态未变。
- [ ] 无硬编码中文；analyze/format/test 干净。

## Notes / hints
- 跨 tab：用 riverpod provider 传数据 + `goBranch` 切 tab（`navigation_shell.dart` 已有 `goBranch`）。注意聊天 branch 的索引（task 25 后 chat=0）。
- 若聊天页已有进行中的一格（`activePlan != null`），composer 不显示——此时"开始这一格"应给出轻提示而非静默（实现者补，PR 说明）。
