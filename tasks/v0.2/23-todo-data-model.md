# 23 — Todo 数据模型 + Drift schema（migration v3）

- **Status:** READY
- **Owner:** Codex
- **Blocked by:** —
- **Allowed new deps:** none

## Goal
为「清单」tab 立地基：domain 的 `Todo` / `TodoLog` 实体与枚举，drift 的 `Todos` / `TodoLogs` 两张表 + `plans.todoId` 列，以及从 v2 升到 v3 的 migration。仅数据层，不含 repository（task 24）和 UI。

## Scope
- in:
  - `lib/domain/todo.dart`：`enum TodoStatus { notStarted, inProgress, paused, done, dropped }`、`enum TodoPriority { p0, p1, p2, permanent }`、`enum TodoLogKind { manual, auto }`；不可变类 `Todo`（`id?`, `seq`, `title`, `status`, `priority`, `dueDate?`, `note?`, `createdAt`, `updatedAt`）与 `TodoLog`（`id?`, `todoId`, `text`, `kind`, `createdAt`），各带 `copyWith` + `==`/`hashCode`（仿 `lib/domain/plan.dart`）。`permanent` 项语义：无 `dueDate`、不参与 `status`（见 DESIGN §2/§3）。
  - `lib/data/db/app_database.dart`：新增 `Todos`、`TodoLogs` 两张 `Table`；给 `Plans` 加 `IntColumn get todoId => integer().nullable()()`；`schemaVersion` 2→3；`onUpgrade` 里 `if (from < 3)` 用 `m.createTable(todos)` / `m.createTable(todoLogs)` / `m.addColumn(plans, plans.todoId)`。枚举列存 `text`（值 = `enum.name`，对齐现有 `status`）。`seq` 为非空 int 列，**加 unique 约束**（`integer().unique()()`），防并发/双击产生重复 `#N`。
  - **seed 默认永久项**：`onCreate` **以及** `onUpgrade(from<3)`（已有用户升级时清单表才刚建）都种入两条 `permanent` todo「吃饭」「睡觉」，占最早的 `seq` `#1`/`#2`。文案走 i18n（en/zh）。
- out: `TodosDao`/`TodoLogsDao`、`TodoRepository`、DI、UI（task 24+）。先不建 DAO（24 一起建）——本 task 到表定义 + 实体 + migration + seed + 生成代码。

## Acceptance criteria
- [ ] `dart run build_runner build` 生成 `app_database.g.dart` 通过；`Todos`/`TodoLogs`/`plans.todoId` 出现在生成代码。
- [ ] `Todo`/`TodoLog` 实体单测：`copyWith` 改单字段、`==`/`hashCode` 行为正确。
- [ ] migration 单测：用 drift 的 schema 测试或 `AppDatabase.forTesting` 在内存库建 v3、能 `createAll`；若可行，补 v2→v3 升级测（参考现有 v1→v2 测）。
- [ ] `seq` 的 unique 约束体现在生成的 schema 里。
- [ ] `flutter analyze` 无新警告；`dart format` 无改动。

## Notes / hints
- 数据模型字段含义见 [DESIGN.md](DESIGN.md) §2。`seq` = 展示序号 `#N`，本 task 只建列；分配逻辑（`max(seq)+1`）在 repository（task 24）。
- 枚举↔text 的读回用 `Values.byName`，未知值抛 `StateError`（仿 `plan_repository_impl.dart` 的 `_statusFromText`）——本 task 实体层先不做映射，留给 24。
- 不要手改 `app_database.g.dart`；用 build_runner 生成。
