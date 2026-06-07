# v0.2 设计 context —「清单」(todo) tab

> 这份文档把「清单 tab」的设计决策、数据模型、交互、架构衔接**一次写清**（**已与 owner 定稿，含「两 APK」战略**）。实现各 task 时以本文为准。
> 视觉设计稿：[`docs/mockups/todo-tab.html`](../../docs/mockups/todo-tab.html) · 线上 <https://orzzzl.github.io/nudge/mockups/todo-tab.html>（5 屏：清单列表 · 新建编辑页 · 详情 · 开始→聊天 · 状态面板）。

## 1. 这个功能是什么

在现有「聊天 / 乖乖图」两个 tab 之间，新增第三个 tab **「清单」**：一个轻量的待办清单，记录"近期想做的事"。它和现有的"一格"（plan / 计时块）打通——可以**不打字**、从清单点一条直接到聊天页开一格；一格做完 check-in 后，自动往那条 todo 的"更新日志"记一笔进展（**但不自动改它的状态**）。

底部 tab 顺序变为：**聊天 💬 / 清单 📋 / 乖乖图 📊**（清单插在中间）。

### 产品定位与「两 APK」战略（已定）

- **本 APK = 离线 MVP，无账号系统。** 清单序号 `#N` 是**纯本地递增**展示号（从 #1、不复用），单设备内有意义即可，**不**追求跨设备/跨人全局唯一。
- **未来联网版 = 另起一个全新 APK**：有账号、支持多人 project 协作；序号由**后端权威发号**、全局唯一连续；**只有联网时能新建清单**。
- **两个 APK 数据不互通**——联网版不导入离线版数据，一切从头开始。好处：离线 MVP 不必背负账号/同步/全局唯一序号的复杂度，**本批就是纯本地**。

## 2. 数据模型

### Todo（一条清单项）
| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | int (autoIncrement) | 主键（drift 内部用）。|
| `seq` | int **unique** | **展示序号 `#N`**。创建时**在事务里**分配 = `max(seq)+1`，**不复用**（删洞没关系，引用稳定优先）；unique 约束防并发/双击重复。用户可用它指代（"开始 #3"）。|
| `title` | text(1..200) | 标题，必填。|
| `status` | text(enum) | 5 态，见下。默认 `notStarted`。**`permanent` 项不适用**。|
| `priority` | text(enum) | `p0`/`p1`/`p2`/`permanent`。默认 `p2`。|
| `dueDate` | dateTime? | 预期完成日期，**仅日期**（存当天 00:00 本地），可空；**`permanent` 项强制为 null**。|
| `note` | text? | "具体内容"备注，可空。|
| `createdAt` | dateTime | |
| `updatedAt` | dateTime | 每次改动更新。|

**TodoStatus**（手动改，**永不自动**）：`notStarted`(未开始) / `inProgress`(进行中) / `paused`(暂停) / `done`(完成) / `dropped`(遗弃)。
**TodoPriority**：`p0` / `p1` / `p2` / **`permanent`(永久)**。颜色：p0 珊瑚红 / p1 蜜桃橙 / p2 抹茶绿 / permanent 薰衣草紫。

**「永久」项**（吃饭/睡觉/打游戏这类无终点的日常）：选 `permanent` → **无截止日期**、**不参与 5 态 status**（列表里无状态图标、不进状态面板）；列表里**单独成一组**「♾️ 永久」、紫色区分。
**seed 默认永久项**：DB 首建（`onCreate`）时种入两条 `permanent` 的 todo「吃饭」「睡觉」，占最早的 `seq` `#1`/`#2`。

### TodoLog（更新日志，一条 todo 多条）
| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | int | |
| `todoId` | int (FK→todos.id) | |
| `text` | text | 一句进展。|
| `kind` | text(enum) | `manual`(用户「＋记一笔」) / `auto`(一格 check-in 后系统记)。|
| `createdAt` | dateTime | |

日志在详情页**时间正序**显示（早在上、新在下）。`auto` 那条视觉上有区分（设计稿②里橙点 + 「做了 1h」小标）。

### plans 表新增一列 + Plan domain
- `plans.todoId` int? —— 一格**来自**哪条 todo（可空；手动输入的格没有）。check-in 回写靠它找到 todo。
- **domain 的 `Plan`（`lib/domain/plan.dart`）也要加 `int? todoId`**（不止 DB 列）：check-in 只拿到 `Plan` 对象，没有这个字段就读不到关联。须纳入 `copyWith`/`==`/`hashCode` 与 `_mapRow`/各查询的 round-trip（见 task 32）。

枚举一律存为 `enum.name` 文本（与现有 `PlanStatus` 一致，见 `plan_repository_impl.dart`）。

## 3. 关键交互（以设计稿为准）

1. **列表（稿①）**：三组 ——「在做·想做」(P0/P1/P2 任务，左侧 5 态图标 + 截止/逾期标红) /「♾️ 永久」(紫色卡片 + 紫「永久」标，**无状态图标、无截止**) /「归档」(done/dropped，划线淡化)。每条 `#序号` + 标题 + 优先级标 + `›`。底部一个**绿色「＋ 新建清单项」按钮**。序号示例：seed 吃饭#1/睡觉#2，用户项 写周报#3…。
2. **新建（稿①b）**：点「＋」→ **跳全屏新建编辑页**（不是对话框）：标题 + 重要程度(P0/P1/P2/永久) + 预期完成(今天/明天/选日期；选「永久」则无此项) + 大备注框 + 「创建」。**创建后回清单列表**。
3. **详情（稿②）默认只读**：标题 `#3 写周报` + 一行 meta(状态/优先级/截止 只读) + 备注 + 更新日志(时间正序) + 底部「▶ 开始这一格」+「⋯」。**编辑靠「⋯」→「编辑」进编辑页**（= 新建页同款表单、预填当前值，改标题/重要程度/截止/备注，保存返回只读）。**例外**：状态改高频 → 详情页**保留一键改状态**快捷（点状态 chip → 稿④面板）。详情页只有底部一个「⋯」（顶栏不再放）。
4. **「⋯」菜单**：**编辑** / **复制为新清单项** / **删除**（红、二次确认）。删除 = hard delete（事务 cascade 删 logs + 解除 `plans.todoId` 关联）。**系统自带永久项（吃饭/睡觉）隐藏「删除」**。
5. **状态改（稿④）**：点状态 chip 弹底部面板，5 选 1，**手动**。一格 check-in 不动它（大任务做一格 ≠ 完成）。`permanent` 项不参与。
6. **开始这一格（稿③）**：从详情触发 → **跳聊天 tab**，composer 任务名放可删 chip「#3 写周报 ×」(携带 `todoId`)；点 × 变回手动输入。时长用**现有 composer 真实控件**（分钟/小时段切换 + 预设 + 自定义），不预填、不弹独立时长面板。不自动改 todo 状态。
7. **check-in 回写**：一格到点 check-in，若 plan 有 `todoId` → 往该 todo 加一条 `auto` 更新日志，记本次**时长 + 结果**（「做了 1h · ✅/🍃/😴」）。**不改 todo 状态。**

## 4. 与现有架构的衔接（落点）

- **DB**：`lib/data/db/app_database.dart` 加 `Todos`、`TodoLogs` 两张表 + `plans.todoId` 列；`schemaVersion` 2→3，`onUpgrade` 里 `from<3` 时 `m.createTable(todos)/m.createTable(todoLogs)` + `m.addColumn(plans, plans.todoId)`。新增 `TodosDao`、`TodoLogsDao`。
- **domain seam**：`lib/domain/todo.dart`（Todo/TodoLog/TodoStatus/TodoPriority，immutable + copyWith + ==/hashCode，仿 `plan.dart`）、`lib/domain/todo_repository.dart`（抽象接口，仿 `plan_repository.dart`）。
- **repo impl**：`lib/data/repositories/todo_repository_impl.dart`（companion insert + `enum.name` + `_mapRow`，仿 `plan_repository_impl.dart`）。
- **DI**：`lib/app/providers.dart` 加 `todoRepositoryProvider`。
- **路由/导航**：`lib/app/app_router.dart` 加第 3 个 `StatefulShellBranch`（`/todos`，**插在 chat 与 stats 之间**）；`lib/app/navigation_shell.dart` 加第 3 个 `NavigationDestination`。
- **UI**：新建 `lib/features/todos/`（screen + controller + widgets），复用 `lib/app/cute_palette.dart` 调色与 `lib/app/widgets/candy.dart` 原语。
- **聊天打通**：改 `lib/features/chat/widgets/plan_composer.dart`（任务名 chip）、`lib/features/chat/chat_controller.dart`（`createPlan` 带 `todoId`、`checkIn` 回写）。跨 tab 预填用一个 riverpod provider（如 `pendingComposerTodoProvider`）。
- **i18n**：所有用户可见文案进 `lib/l10n/app_en.arb` + `app_zh.arb`（**硬规则：lib/test 内不得出现中文**，CI 有 `rg \p{Han}` 守卫）。品牌名 zh =「下一格」，右上入口 = ⚙️ 设置（已是现状）。

## 5. 已定 / 待定

- **删除（已定）**：详情「⋯」→「删除」= **hard delete**，事务内 cascade 删该 todo 的 logs + 把 `plans.todoId == id` 置 null（防 FK 失败/悬空），**二次确认**；**自带永久项（吃饭/睡觉）隐藏删除**。「遗弃」(`dropped`) 是另一回事 —— 不想做了但留痕、沉「归档」。check-in 回写（task 34）对"todo 已不存在"**no-op** 防御。
- **check-in 自动日志（已定）**：记**时长 + 结果**（做了 1h · ✅/🍃/😴）。
- **列表默认排序（待定）**：暂定活跃组按 `优先级 asc, 截止 asc, seq asc`，永久组按 `seq`，归档组按 `updatedAt desc`。
- **到期/逾期提醒（后续，不在本批）**：依赖现有 `ReminderScheduler` seam，单列后续 task。
- **分类/标签（本批不做）**。

## 6. 拆分原则

每个 task = 一个可独立评审的 PR 量级，依赖关系标在 `Blocked by`。数据层（23–24）是地基；UI（25–31）多数可在 mock repository 上独立推进；聊天打通（32–34）放最后。每个 task 自带测试，UI task 自带 i18n（不单列 i18n task）。详见 [README.md](README.md) 的路线表与各 `NN-*.md`。
