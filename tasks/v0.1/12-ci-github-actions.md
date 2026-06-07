# 12 — CI (GitHub Actions)

- **Status:** DONE (implemented by Claude; merged in PR #7)
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** — (independent; valuable early to protect `main`)
- **Allowed new deps:** none (CI config only)

## Goal
Run format/analyze/test automatically on every PR and on pushes to `main`, so green status stops
depending on someone running the checks locally.

## Scope
- in:
  - `.github/workflows/ci.yml`: checkout → set up Flutter **stable pinned to 3.44.x** (match local) →
    `flutter pub get` (this regenerates the gitignored l10n) → `dart format --set-exit-if-changed .`
    → `flutter analyze` → `flutter test`. Cache the pub cache.
  - Trigger on `pull_request` and `push` to `main`.
- out:
  - No build/release artifacts, no device/integration tests, no coverage upload, no signing.

## Acceptance criteria (draft)
- [ ] The workflow runs on PRs and on `main`, and fails on a format/analyze/test error.
- [ ] It passes on the current `main` (drift `*.g.dart` is committed; l10n regenerates via pub get).
- [ ] Flutter version is pinned (not "latest") to avoid surprise breakage.

## Notes / hints
- Because `lib/l10n/generated/` is gitignored, `flutter pub get` must run before analyze/test — it
  does, so no extra step. Drift `*.g.dart` is committed, so no build_runner step is needed in CI.
- Use the official `subosito/flutter-action` (or equivalent) pinned by version.
- **`pubspec.lock`**: currently gitignored (apps usually commit it for reproducible CI). Not a
  blocker — CI resolves fresh each run. When dispatching this task, decide whether to also start
  committing `pubspec.lock` (recommended for an app) so CI is fully reproducible; if so, flip the
  `.gitignore` line in the same PR.
