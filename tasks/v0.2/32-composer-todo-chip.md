# 32 — 聊天 composer 支持「来自清单」任务名 chip + plan 关联 todoId

- **Status:** READY
- **Owner:** Codex
- **Blocked by:** 23 ✅ (merged, PR #42)
- **Allowed new deps:** none

## Goal
改造现有 `PlanComposer`：任务名字段可承载一个**来自清单的可删 chip**「#1 写周报 ×」，点 `×` 删掉变回普通手动输入；开一格时把 `todoId` 一路带到 plan（为 task 34 的 check-in 回写铺路）。**时长控件保持现状不动**（分钟/小时段切换 + 预设 + 自定义）。

## Scope
- in:
  - `lib/features/chat/widgets/plan_composer.dart`：任务名区支持两态——(a) 普通 `TextField`（现状），(b) 当带入一个 `({int todoId, int seq, String title})` 时，显示一个 chip「#seq title ×」占位任务名；点 `×` 清掉 → 回到 (a) 手动输入。`onStart` 回调签名增加可选 `int? todoId`。
  - `lib/features/chat/chat_controller.dart`：`createPlan(...)` 增加可选 `int? todoId`，落到 `plans.todoId`（drift 写入）。
  - **`lib/domain/plan.dart`：给 `Plan` 加 `int? todoId` 字段，纳入 `copyWith` / `==` / `hashCode`（采纳 Codex 审核）。** 否则 task 34 的 `checkIn` 只拿到 `Plan`、读不到关联。
  - `lib/data/repositories/plan_repository_impl.dart` + `PlanRepository.createPlan` + `PlansDao.insertPlan`：透传 `todoId`（可空）写入；**`_mapRow` 读出 `todoId`，并让 `getActivePlan` / `getPlanById` / `watchPlansForDay` / `watchPlansInRange` 返回的 `Plan` 都带上 `todoId`（round-trip）**——恢复 active plan、通知点击 `getPlanById`、check-in 都要读得到。
  - 入口数据来自一个 provider（如 `pendingComposerTodoProvider`，由 task 33 设置；本 task 定义该 provider 并让 composer 读取/消费它，task 33 负责写入）。
  - i18n：无新增用户文案（chip 显示的是 todo 标题）。
- out: 「开始这一格」从详情/列表触发跳转（task 33）；check-in 回写（task 34）。

## Acceptance criteria
- [ ] 单测/widget test：composer 带入 todo → 显示 chip；点 × → 变回输入框、`onStart` 的 `todoId` 为 null；带 chip 开始 → `createPlan(todoId:)` 收到 id。
- [ ] `plans.todoId` 持久化 + **`Plan.todoId` round-trip**：`createPlan(todoId:)` 后 `getActivePlan` / `getPlanById` 读回的 `Plan.todoId` 一致；`watchPlans*` 返回的 `Plan` 也带 `todoId`；手动输入（无 todoId）→ `Plan.todoId == null`。
- [ ] 现有 composer 行为（手动输入、时长选择、空标题提示）回归测试仍过。
- [ ] 无硬编码中文；analyze/format/test 干净。

## Notes / hints
- 现有 composer 结构见 `plan_composer.dart`（`_titleController` + 预设 chips + `_UnitToggle` + `CandyButton`）——**只动任务名那一段**，时长部分别改。
- `pendingComposerTodoProvider`：建议 `StateProvider<({int todoId,int seq,String title})?>`，composer 在 build 时读取、用后置空。
