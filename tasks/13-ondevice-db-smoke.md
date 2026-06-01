# 13 — On-device DB smoke test (CI hardening)

- **Status:** READY
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** 02 (Drift DB) + 12 (CI) — both DONE
- **Allowed new deps:** `integration_test` (Flutter SDK, dev_dependency only) — no third-party deps.

## Goal
Host `flutter test` runs on the dev machine's / CI runner's own sqlite3, so it **cannot** catch
on-device native-lib breakage — exactly the class of bug that shipped in
`sqlite3_flutter_libs 0.6.0+eol` (a no-native-libs stub that crashed the app the first time it
touched the DB; fixed → `^0.5.42` in PR #9). Add an `integration_test` that opens the **real** app
database on an Android emulator and does a round-trip, plus a CI job that runs it — so a future
plugin/dep bump that drops the native libs fails CI instead of reaching a device.

## Design (locked against the real setup)

### The test — `integration_test/db_smoke_test.dart`
- `IntegrationTestWidgetsFlutterBinding.ensureInitialized();` at the top of `main()`.
- Construct the **real** `AppDatabase()` (the default constructor → `_openConnection()` →
  `path_provider` + native sqlite3). Do **NOT** use `AppDatabase.forTesting` and do **NOT** use an
  in-memory executor — the whole point is to exercise the on-disk native path.
- Drive it through the real repository: `PlanRepositoryImpl(db.plansDao)`
  (`lib/data/repositories/plan_repository_impl.dart`). Round-trip:
  1. `createPlan(title: 'smoke', durationMin: 30, startAt: <now>, locale: 'en')` → returns a `Plan`
     with a non-null `id`.
  2. `getPlanById(id)` → non-null, title/duration match, `status == PlanStatus.running`.
  3. `checkIn(id: id, status: PlanStatus.done)`.
  4. `getPlanById(id)` → `status == PlanStatus.done` (proves write+read survive a real query).
- Close the DB in a `tearDown`/`addTearDown` (`await db.close()`). Keep the test hermetic: it's fine
  to leave the on-disk file; if you prefer isolation, delete the DB file before opening (reuse the
  same path logic — don't hard-code).
- This is a `testWidgets`/`test` in the integration harness, not a full app pump — keep it to the DB
  layer so it's fast and focused. No need to launch `NudgeApp`.

### The CI job — extend `.github/workflows/` (do NOT slow the existing fast `check` job)
- Add a **separate** job (new file `android-smoke.yml`, or a second job in `ci.yml`) named e.g.
  `android-db-smoke`, using `reactivecircle/android-emulator-runner@v2` on `ubuntu-latest` (it
  enables KVM). Pin: `api-level: 34`, `arch: x86_64`, a stable `target`/profile.
- Steps: checkout → `subosito/flutter-action@v2` pinned to `flutter-version: 3.44.0` (match the
  existing job + local dev) → `flutter pub get` → inside the emulator-runner `script:`
  run `flutter test integration_test/db_smoke_test.dart` (runs on the booted emulator).
- **Keep it cheap / avoid taxing every PR:** gate this job with a `paths:` filter so it only runs
  when DB/native/dep surface changes — e.g. `lib/data/**`, `pubspec.yaml`, `pubspec.lock`,
  `android/**`, `ios/**`, and the workflow file itself — plus on `push` to `main`. The existing
  `check` job (format/analyze/test) stays unchanged and keeps running on every PR.
- Add `flutter-version`/Java caching as the existing workflow does, so the only real cost is emulator
  boot.

## Out of scope
- No change to app code or the schema; this is test + CI only (touching `lib/` is a smell here — if
  the test needs a hook, prefer using the existing public constructors/repository).
- Not a full end-to-end UI integration test — just the DB native-path smoke. (Broader on-device UI
  flows stay manual; see `docs/device-verify.md`.)
- Don't migrate the existing host unit tests into integration tests; they stay as the fast layer.

## Acceptance criteria
- [ ] `integration_test/db_smoke_test.dart` opens the real `AppDatabase()` and passes a
      create → read → check-in → read round-trip through `PlanRepositoryImpl`.
- [ ] Running it on the local Android emulator passes:
      `flutter test integration_test/db_smoke_test.dart -d emulator-5554`.
- [ ] A CI job runs the smoke test on an emulator, is `paths:`-gated to DB/native/dep changes (+ main),
      and does **not** add latency to the existing `check` job on unrelated PRs.
- [ ] Deliberately reproduces the original failure mode in spirit: if the native libs were missing
      (as in `0.6.0+eol`), this test would fail. (No need to actually break the dep — just confirm the
      test exercises `_openConnection()`/native sqlite3, not a mock.)
- [ ] `integration_test` added under `dev_dependencies` only.
- [ ] `dart format .` / `flutter analyze` / `flutter test` (host) all still clean; the new file lives
      under `integration_test/` so it doesn't run in the host `flutter test` pass.

## Notes / hints
- `_openConnection()` in `lib/data/db/app_database.dart` uses `getApplicationDocumentsDirectory()` +
  native `drift`/`sqlite3` — that's the exact path this test must hit.
- `reactivecircle/android-emulator-runner` README has the canonical `api-level`/`arch`/`script`
  recipe and the KVM setup; mirror it.
- Emulator CI is the slowest job by far — that's why it's `paths:`-gated. Call out in the workflow
  comment that it intentionally doesn't gate unrelated PRs.
- This closes the "On-device DB smoke test" follow-up tracked under **Later** in `tasks/README.md`.
