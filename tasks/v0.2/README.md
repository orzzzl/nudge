# tasks · v0.2

`0.2.0` 开发周期。第一个大功能是 **「清单」tab**（todo）。

- 设计 context（**先读**）：[DESIGN.md](DESIGN.md)
- 视觉稿：[`docs/mockups/todo-tab.html`](../../docs/mockups/todo-tab.html) · 线上 <https://orzzzl.github.io/nudge/mockups/todo-tab.html>

## 路线（清单 tab — 拆成可独立派发的 12 个 task）

| # | 任务 | 状态 | Blocked by |
|---|------|------|------------|
| 23 | [Todo 数据模型 + Drift schema（migration v3）](23-todo-data-model.md) | READY | — |
| 24 | [TodoRepository seam + Drift 实现 + DI](24-todo-repository.md) | BLOCKED | 23 |
| 25 | [接入第三个「清单」tab（路由+导航+占位页）](25-todos-tab-shell.md) | DONE (Claude, PR #41) | — |
| 26 | [清单列表页（controller + 分组列表 UI）](26-todos-list.md) | BLOCKED | 24, 25 |
| 27 | [添加 todo（「＋」入口）](27-todos-add.md) | BLOCKED | 26 |
| 28 | [详情页骨架（标题 + 备注 + meta 展示）](28-todos-detail.md) | BLOCKED | 24, 26 |
| 29 | [详情：状态编辑（5 态面板）](29-todos-status-edit.md) | BLOCKED | 28 |
| 30 | [详情：优先级 + 截止日期编辑](30-todos-priority-due-edit.md) | BLOCKED | 28 |
| 31 | [更新日志（时间线 + 手动记一笔）](31-todos-update-log.md) | BLOCKED | 24, 28 |
| 32 | [composer「来自清单」chip + plan 关联 todoId](32-composer-todo-chip.md) | BLOCKED | 23 |
| 33 | [「开始这一格」从清单跳聊天预填](33-start-from-todo.md) | BLOCKED | 28, 32, 25 |
| 34 | [check-in 回写更新日志（auto，不改状态）](34-checkin-writeback.md) | BLOCKED | 24, 32 |

**起步可并行**：`23`（数据模型）和 `25`（tab 壳）无依赖，可同时开；`32` 只等 `23`。其余按 `Blocked by` 解锁。
每个 task 自带测试，UI task 自带 i18n（**lib/test 内不得有中文**，CI `rg \p{Han}` 守卫）。

## 设计阶段待拍板（见 [DESIGN.md](DESIGN.md) §5，落到对应 task 前定）

- 列表默认排序；到期/逾期提醒（单列后续 task，不在本批）；分类/标签（本批不做）；check-in 自动日志是否带 ✅🍃😴（暂定带）；硬删除 vs 仅"遗弃"。

> 账号系统 / 云同步（中美 region-split）另议，暂缓 —— 见项目讨论。
