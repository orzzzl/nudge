# v0.2 设计 context —「清单」(todo) tab

> 这份文档把 v0.2 第一个大功能「清单 tab」的设计决策、数据模型、交互、与现有架构的衔接、以及尚未拍板的点**一次写清**，供 Codex 审核（和实现各 task 时回看）。**先审核这份 + 各 task，再发布。**
> 视觉设计稿：[`docs/mockups/todo-tab.html`](../../docs/mockups/todo-tab.html) · 线上 <https://orzzzl.github.io/nudge/mockups/todo-tab.html>（4 屏：①清单列表 ②详情 ③开始→聊天 ④状态面板）。

## 1. 这个功能是什么

在现有「聊天 / 乖乖图」两个 tab 之间，新增第三个 tab **「清单」**：一个轻量的待办清单，记录"近期想做的事"。它和现有的"一格"（plan / 计时块）打通——可以**不打字**、从清单点一条直接到聊天页开一格；一格做完 check-in 后，自动往那条 todo 的"更新日志"记一笔进展（**但不自动改它的状态**）。

底部 tab 顺序变为：**聊天 💬 / 清单 📋 / 乖乖图 📊**（清单插在中间）。

## 2. 数据模型

### Todo（一条清单项）
| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | int (autoIncrement) | 主键（drift 内部用）。|
| `seq` | int | **展示序号 `#N`**。创建时分配 = `max(seq)+1`，**不复用**（删除留洞没关系，引用稳定优先）。用户可用它指代（"开始 #3"）。|
| `title` | text(1..200) | 标题，必填。|
| `status` | text(enum) | 5 态，见下。默认 `notStarted`。|
| `priority` | text(enum) | `p0`/`p1`/`p2`。默认 `p2`。|
| `dueDate` | dateTime? | 预期完成日期，**仅日期**（存当天 00:00 本地），可空。|
| `note` | text? | "具体内容"备注，可空。|
| `createdAt` | dateTime | |
| `updatedAt` | dateTime | 每次改动更新（为未来同步铺路）。|

**TodoStatus**（手动改，**永不自动**）：`notStarted`(未开始) / `inProgress`(进行中) / `paused`(暂停) / `done`(完成) / `dropped`(遗弃)。
**TodoPriority**：`p0` / `p1` / `p2`（无更细分；颜色：p0 珊瑚红 / p1 蜜桃橙 / p2 抹茶绿）。

### TodoLog（更新日志，一条 todo 多条）
| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | int | |
| `todoId` | int (FK→todos.id) | |
| `text` | text | 一句进展。|
| `kind` | text(enum) | `manual`(用户「＋记一笔」) / `auto`(一格 check-in 后系统记)。|
| `createdAt` | dateTime | |

日志在详情页**时间正序**显示（早在上、新在下）。`auto` 那条视觉上有区分（设计稿②里橙点 + 「做了 1h」小标）。

### plans 表新增一列
- `plans.todoId` int? —— 一格**来自**哪条 todo（可空；手动输入的格没有）。check-in 回写靠它找到 todo。

枚举一律存为 `enum.name` 文本（与现有 `PlanStatus` 一致，见 `plan_repository_impl.dart`）。

## 3. 关键交互（以设计稿为准）

1. **列表（稿①）**：左侧状态图标一眼辨状态；`#序号` + 标题；第二行截止日期（逾期标红）+ 状态/内容预览；右侧优先级小标 `P0/P1/P2` + `›`。完成/遗弃沉到「归档」分组、划线淡化。底部常驻「＋ 还想做点什么」。
2. **详情（稿②）**：标题 `#1 写周报`；标题下**一行** = 可点编辑的 `状态 ⌄` / `P0 ⌄` / `📅 截止 ⌄`；下面「具体内容」备注；最下「更新日志」时间线 + 「＋ 记一笔进展」；底部「▶ 开始这一格」+「⋯」。
3. **状态改（稿④）**：点状态 `⌄` 弹底部面板，5 选 1。**只有手动能改状态**——一格 check-in 不动它（大任务做两小时 ≠ 做完）。
4. **开始这一格（稿③）**：从详情/列表触发 → **跳到聊天 tab**，聊天 composer 的任务名字段自动放一个**可删 chip**「#1 写周报 ×」（携带 `todoId`）；点 `×` 删掉就变回普通手动输入。时长用**现有 composer 的真实控件**（分钟/小时段切换 + 预设 + 自定义），不预填、不弹独立时长面板。
5. **check-in 回写**：一格到点 check-in 后，若该 plan 有 `todoId`，往那条 todo 的更新日志加一条 `auto` 记录（如「做了 1h · ✅」）。**不改 todo 状态。**

## 4. 与现有架构的衔接（落点）

- **DB**：`lib/data/db/app_database.dart` 加 `Todos`、`TodoLogs` 两张表 + `plans.todoId` 列；`schemaVersion` 2→3，`onUpgrade` 里 `from<3` 时 `m.createTable(todos)/m.createTable(todoLogs)` + `m.addColumn(plans, plans.todoId)`。新增 `TodosDao`、`TodoLogsDao`。
- **domain seam**：`lib/domain/todo.dart`（Todo/TodoLog/TodoStatus/TodoPriority，immutable + copyWith + ==/hashCode，仿 `plan.dart`）、`lib/domain/todo_repository.dart`（抽象接口，仿 `plan_repository.dart`）。
- **repo impl**：`lib/data/repositories/todo_repository_impl.dart`（companion insert + `enum.name` + `_mapRow`，仿 `plan_repository_impl.dart`）。
- **DI**：`lib/app/providers.dart` 加 `todoRepositoryProvider`。
- **路由/导航**：`lib/app/app_router.dart` 加第 3 个 `StatefulShellBranch`（`/todos`，**插在 chat 与 stats 之间**）；`lib/app/navigation_shell.dart` 加第 3 个 `NavigationDestination`。
- **UI**：新建 `lib/features/todos/`（screen + controller + widgets），复用 `lib/app/cute_palette.dart` 调色与 `lib/app/widgets/candy.dart` 原语。
- **聊天打通**：改 `lib/features/chat/widgets/plan_composer.dart`（任务名 chip）、`lib/features/chat/chat_controller.dart`（`createPlan` 带 `todoId`、`checkIn` 回写）。跨 tab 预填用一个 riverpod provider（如 `pendingComposerTodoProvider`）。
- **i18n**：所有用户可见文案进 `lib/l10n/app_en.arb` + `app_zh.arb`（**硬规则：lib/test 内不得出现中文**，CI 有 `rg \p{Han}` 守卫）。品牌名 zh =「下一格」，右上入口 = ⚙️ 设置（已是现状）。

## 5. 尚未拍板（实现到对应 task 前，需 owner 定）

- **列表默认排序**：优先级 / 截止日期 / 手动拖 / 按状态分组？（暂定：活跃组按 `优先级 asc, 截止 asc, seq asc`，归档组按 `updatedAt desc`。）
- **到期 / 逾期提醒**：要不要到日子推通知？（依赖现有 `ReminderScheduler` seam，**单列为后续 task，不在本批 MVP**。）
- **分类 / 标签**（工作/学习/生活）：留不留？面板分组与筛选依赖它。（暂**不做**，本批不含。）
- **check-in 自动日志**是否带 `✅/🍃/😴` 结果？（暂定：**带**。）
- **删除 vs 遗弃**：「遗弃」是状态（保留留痕）；是否还需要硬删除？（暂定：详情「⋯」里提供"删除"，列表不直接删。）

## 6. 拆分原则

每个 task = 一个可独立评审的 PR 量级，依赖关系标在 `Blocked by`。数据层（23–24）是地基；UI（25–31）多数可在 mock repository 上独立推进；聊天打通（32–34）放最后。每个 task 自带测试，UI task 自带 i18n（不单列 i18n task）。详见 [README.md](README.md) 的路线表与各 `NN-*.md`。
