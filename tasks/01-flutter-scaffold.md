# 01 — Flutter project scaffold

- **Status:** DONE
- **Owner:** Codex
- **Blocked by:** —
- **Allowed new deps:** flutter_riverpod, go_router, intl; dev: build_runner, custom_lint, riverpod_lint

## Goal
Stand up an empty-but-runnable Flutter app for iOS + Android with the agreed layered folder
structure, so later tasks have a place to put code. No features yet — just a scaffold that
builds, analyzes clean, and shows a two-tab shell (聊天 / 乖乖图) with placeholder screens.

## Scope
- in:
  - `flutter create` the project at repo root (org id: `com.nudge.app`, platforms: ios, android).
  - Create the folder structure from `docs/tech-design.md` §11 under `lib/`
    (`app/`, `core/`, `domain/`, `data/`, `features/{chat,stats,pet,settings}`, `l10n/`).
  - Add a `go_router` config with two routes and a bottom `TabBar`/`NavigationBar` shell:
    Chat tab and Stats tab, each a placeholder `Scaffold` with a centered label.
  - Wire `ProviderScope` (Riverpod) at the app root.
  - Set up `flutter_lints` + `custom_lint`/`riverpod_lint`; ensure `flutter analyze` is clean.
- out:
  - No database, no notifications, no pet, no real UI. No i18n content yet (next tasks).
  - Do not implement any of the four domain interfaces.

## Acceptance criteria
- [x] `flutter run` launches on both an iOS simulator and an Android emulator. (verified — issue #2)
- [ ] App shows a bottom navigation with two tabs that switch between two placeholder screens.
- [ ] Folder structure matches docs/tech-design.md §11.
- [ ] `dart format .` clean, `flutter analyze` clean, `flutter test` passes (default widget test ok).
- [ ] No Google Play Services dependency added.

## Notes / hints
- Keep `main.dart` thin: `runApp(ProviderScope(child: NudgeApp()))`.
- Put router + theme under `lib/app/`.
- Use `NavigationBar` (Material 3). Theme can be minimal; final visual comes later.
