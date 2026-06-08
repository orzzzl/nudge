# 26 — 清单列表页（controller + 分组列表 UI）

- **Status:** BLOCKED
- **Owner:** Codex
- **Blocked by:** 24, 25
- **Allowed new deps:** none

## Goal
把占位的清单页换成真实列表（设计稿①）：分组、状态图标、序号、优先级、截止，点条目进详情。

## Scope
- in:
  - `lib/features/todos/todos_controller.dart`：Notifier/AsyncNotifier，watch `todoRepository.watchTodos()`，拆成**三组**——**活跃**（非永久任务里 `notStarted`/`inProgress`/`paused`）、**♾️ 永久**（`priority==permanent`，紫色卡片 + 紫「永久」标、**无状态图标、无截止**）、**归档**（`done`/`dropped`，划线淡化）。
  - `lib/features/todos/todos_screen.dart` + `widgets/todo_list_item.dart`：
    - 列表项：左 5 态图标（未开始空心○ / 进行中▶ / 暂停⏸ / 完成✓ / 遗弃✕，配色见设计稿）；`#seq`；标题；第二行 = 截止（逾期 `dueDate < today` 标红）+ 状态/备注预览；右 `P0/P1/P2` 小标 + `›`。归档项划线淡化（用颜色，**不用 `opacity`**，见下）。
    - 分组标题「在做 · 想做」/「归档」。空状态（无 todo 时团团语气）。
    - 点整条 → 进详情（路由占位即可，详情在 task 28）。
  - i18n：分组标题、状态名、空状态等文案（en/zh）。
- out: 添加（27）、详情（28+）、聊天打通。

## Acceptance criteria
- [ ] widget test（override `todoRepositoryProvider` 为内存/假实现）：渲染活跃+归档分组、5 态图标、序号、优先级、逾期标红；空状态；点条目触发导航。
- [ ] 无硬编码中文；analyze/format/test 干净。

## Notes / hints
- **坑（务必避免）**：归档项淡化**不要用 `opacity` + 也不要复用名为 `dim` 的 class**——设计稿调试时发现 `.titem.dim` 撞了全屏遮罩 class、`opacity` 在圆角+overflow 容器里触发整屏发白。Flutter 侧用更淡的背景/文字色表达即可。
- 配色全部走 `lib/app/cute_palette.dart`；卡片/阴影用 `lib/app/widgets/candy.dart` 原语。视觉对照 `docs/mockups/todo-tab.html` 稿①。
- 排序若 repository 已排好就直接用；否则在 controller 里按 [DESIGN.md](DESIGN.md) §5 暂定规则排。
