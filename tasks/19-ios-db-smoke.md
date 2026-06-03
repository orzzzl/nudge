# 19 — iOS DB smoke test (CI hardening)

- **Status:** DONE (PR #24)
- **Owner:** Claude (self-merged — Codex on leave)
- **Blocked by:** 13 (Android DB smoke) — DONE
- **Allowed new deps:** none (CI/workflow only).

## Goal
Extend the on-device DB smoke coverage from task 13 to **iOS**. Android and iOS link the native
`sqlite3` engine through completely different toolchains — Android via Gradle, iOS via Swift Package
Manager (Flutter 3.44 + Xcode 26; CocoaPods is no longer used). A dependency/plugin bump can drop the
native libs on one platform while the other stays green, so verifying only Android leaves the iOS
native path unguarded — the exact `sqlite3_flutter_libs 0.6.0+eol` failure mode task 13 exists to
catch.

## Design
- **No new test.** `integration_test/db_smoke_test.dart` is platform-agnostic and is reused as-is.
- Rename `.github/workflows/android-smoke.yml` → `db-smoke.yml`; workflow name
  `Android DB Smoke` → `On-device DB Smoke` (it now covers both platforms). Update the `paths:`
  self-reference; `ios/**` was already in the filter.
- Keep the existing `android-db-smoke` job unchanged. Add a parallel `ios-db-smoke` job:
  - `runs-on: macos-latest` (needed for the iOS Simulator).
  - `subosito/flutter-action@v2` pinned to `flutter-version: 3.44.0` → `flutter pub get`.
  - Boot the first available iPhone simulator, resolving its UDID dynamically (model names vary by the
    runner's Xcode version), and `xcrun simctl bootstatus … -b` to wait.
  - `flutter test integration_test/db_smoke_test.dart -d "$SIM_UDID"`.
- Same `paths:` gating as task 13 — does not add latency to the fast `check` job on unrelated PRs.

## Out of scope
- No app/schema/test changes — workflow only.
- Not a full iOS UI integration test; just the DB native-path smoke.

## Acceptance criteria
- [x] `ios-db-smoke` runs the smoke test on a booted iOS Simulator and passes.
- [x] Android job and `paths:` gating preserved; fast `check` job untouched.
- [x] Verified locally on an iPhone 17 Pro simulator (Xcode build + native sqlite3 round-trip pass);
      confirmed green on the macOS CI runner via PR #24.
