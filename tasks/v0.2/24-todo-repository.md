# 24 — TodoRepository seam + Drift 实现 + DI

- **Status:** BLOCKED
- **Owner:** Codex
- **Blocked by:** 23
- **Allowed new deps:** none

## Goal
在 task 23 的表上，做出 `TodoRepository`（domain 抽象 seam）+ drift 实现 + DAO + riverpod provider，让 UI 层能在接口上工作。

## Scope
- in:
  - `lib/domain/todo_repository.dart`（抽象类，仿 `plan_repository.dart`）：
    - `Stream<List<Todo>> watchTodos()`（按 [DESIGN.md](DESIGN.md) §5 暂定排序：活跃组 `priority asc, dueDate asc nulls last, seq asc`，归档组 `updatedAt desc`；或先按 `seq` 返回、分组/排序交给 controller——**实现者二选一并在 PR 说明**）。
    - `Future<Todo> getTodoById(int id)` / `Future<Todo?>`。
    - `Future<Todo> createTodo({required String title, TodoPriority priority = TodoPriority.p2, DateTime? dueDate})`（分配 `seq = max(seq)+1`，`status=notStarted`，`createdAt/updatedAt=now`）。
    - `Future<void> updateTodo({required int id, String? title, TodoStatus? status, TodoPriority? priority, DateTime? dueDate, bool clearDueDate, String? note, bool clearNote})`（任一字段，更新 `updatedAt`）。
    - `Future<void> deleteTodo(int id)`。
    - `Stream<List<TodoLog>> watchLogs(int todoId)`（按 `createdAt asc` 正序）+ `Future<void> addLog({required int todoId, required String text, required TodoLogKind kind})`。
  - `lib/data/db/app_database.dart`：`TodosDao`、`TodoLogsDao`（`@DriftAccessor`）。
  - `lib/data/repositories/todo_repository_impl.dart`：实现 + `_mapRow`/`_mapLog` + 枚举 `byName`（仿 `plan_repository_impl.dart`）。
  - `lib/app/providers.dart`：`final todoRepositoryProvider = Provider<TodoRepository>(...)`（用 `appDatabaseProvider`）。
- out: 任何 UI；聊天打通；`plans.todoId` 的写入（在 task 32）。

## Acceptance criteria
- [ ] 单测（`AppDatabase.forTesting` 内存库，仿现有 dao/repo 测）：create 分配递增 `seq` 且不复用（删后新建 seq 继续增）；update 各字段 + `clearDueDate`/`clearNote`；watchTodos 发射更新；addLog + watchLogs 正序。
- [ ] `flutter analyze` 干净；`dart format` 无改动；`flutter test` 通过。

## Notes / hints
- `nulls last` 排序：drift 没有直接的 nulls-last，可用 `OrderingTerm`（`dueDate IS NULL` 先排）或在 Dart 侧排——实现者择一。
- `clearDueDate`/`clearNote` 这种"显式置空"沿用 `plan.dart` 里 `copyWith` 的 `_unset` 思路或布尔开关。
