# 10 — Settings + 勿扰 (do-not-disturb)

- **Status:** READY
- **Owner:** Codex, or Claude if Codex is low on budget (Codex reviews)
- **Blocked by:** 03 (i18n), 05 — both DONE
- **Allowed new deps:** `shared_preferences` + `package_info_plus` (add to `dependencies:` in
  `pubspec.yaml` with caret ranges, e.g. `shared_preferences: ^2.3.0`, `package_info_plus: ^8.1.0`;
  resolve with `flutter pub get`). No others. Settings live in shared_preferences (a few key-values;
  Drift would be overkill); the About version is read at runtime via package_info_plus (never hard-coded).

## Goal
Add a ⚙️ settings entry and a minimal settings surface: a do-not-disturb toggle, a manual language
override (zh / en / follow system), and a basic about section.

## Design (locked against the real interfaces)

### Settings model + store seam
Follow the existing seam style (`PlanRepository`/`ReminderScheduler` in `lib/domain/` + impl in
`lib/data/` + provider in `lib/app/providers.dart`), so tests inject an in-memory fake via a provider
override (no `SharedPreferences` calls in tests).
- New `lib/domain/app_settings.dart`: an immutable `AppSettings { bool dnd; LocaleOverride localeOverride }`
  (with `copyWith` + value equality), plus `enum LocaleOverride { system, en, zh }`. Add a getter
  `Locale? resolvedLocale` → `null` for `system`, `Locale('en')` / `Locale('zh')` otherwise.
- New `lib/domain/settings_repository.dart`: `abstract class SettingsRepository` with
  `Future<AppSettings> load()`, `Future<void> setDnd(bool)`, `Future<void> setLocaleOverride(LocaleOverride)`.
- New `lib/data/settings/shared_prefs_settings_repository.dart`: implements it over
  `SharedPreferences` (keys e.g. `settings.dnd` bool, `settings.localeOverride` string = enum `.name`,
  absent/unknown → defaults `dnd: false`, `localeOverride: system`). Call
  `SharedPreferences.getInstance()` inside the impl.

### Providers — `lib/app/providers.dart`
- `settingsRepositoryProvider` → `Provider<SettingsRepository>` returning the shared-prefs impl
  (overridable in tests, like `reminderSchedulerProvider`).
- `settingsControllerProvider` → `NotifierProvider<SettingsController, AppSettings>`.
  `SettingsController extends Notifier<AppSettings>`: `build()` returns the **sync default**
  (`AppSettings(dnd: false, localeOverride: LocaleOverride.system)`) and kicks off
  `unawaited(_load())` to hydrate from the repo and update `state` — mirror `ChatController._restoreActivePlan`.
  Mutators `setDnd(bool)` / `setLocaleOverride(LocaleOverride)` update `state` immediately **and**
  persist via the repository.

### Locale wiring — `lib/app/nudge_app.dart`
- `ref.watch(settingsControllerProvider)` and pass `locale: settings.resolvedLocale` to
  `MaterialApp.router`. `system` → `null` (Flutter falls back to device locale, current behavior).
  Override flips the UI live because the provider rebuild re-renders `MaterialApp`.

### Entry point + route (decided: shell-level app bar)
- Add a shared `AppBar` to the `Scaffold` in `lib/app/navigation_shell.dart` (shows on both tabs):
  title = `AppLocalizations.of(context).appTitle`, with a trailing `IconButton(Icons.settings)`
  (tooltip = a new i18n string) that calls `context.push('/settings')`. The inner chat/stats
  Scaffolds stay body-only.
- Add a **top-level** `GoRoute(path: '/settings', ...)` in `lib/app/app_router.dart`, declared
  **outside** the `StatefulShellRoute` (a full-screen push with its own back button), pointing at the
  new `SettingsScreen`.

### Settings screen — `lib/features/settings/settings_screen.dart`
- `Scaffold` + `AppBar` (back button + localized title). Body is a simple list:
  - **DND**: `SwitchListTile` bound to `settings.dnd` → `controller.setDnd`.
  - **Language**: three options (System / English / 中文) — e.g. `RadioListTile<LocaleOverride>` or a
    segmented control — bound to `settings.localeOverride` → `controller.setLocaleOverride`.
  - **About**: app name + version. Read version via `package_info_plus`
    (`PackageInfo.fromPlatform()`), exposed through an overridable `packageInfoProvider`
    (`FutureProvider<PackageInfo>`) so tests can stub it; render with `.when(...)`.

### i18n — add to BOTH `lib/l10n/app_en.arb` and `lib/l10n/app_zh.arb` (then `flutter pub get` to
regenerate `lib/l10n/generated/`)
Suggested keys (match the existing `@`-description style): `settingsTitle`, `settingsEntryTooltip`,
`settingsDndLabel`, `settingsDndDescription`, `settingsLanguageLabel`, `settingsLanguageSystem`,
`settingsLanguageEnglish`, `settingsLanguageChinese`, `settingsAboutLabel`,
`settingsVersionValue` (placeholder `{version}`, type String).

## Out of scope
- DND only **stores** the pref this task. Do **not** wire it into task-07 reminder scheduling — the
  per-plan reminder stays user-controllable; DND will gate *future* re-engagement nudges only.
- No re-engagement notifications, no account/profile, no theme switching.

## Acceptance criteria
- [ ] ⚙️ in the shared app bar opens the settings screen from either tab.
- [ ] Settings persist across an app restart (round-trip through shared_preferences).
- [ ] Language override switches the UI locale immediately and persists; "System" follows the device.
- [ ] DND toggle is stored and readable via `settingsControllerProvider` by other code.
- [ ] About shows the app name + the runtime version from `package_info_plus` (not hard-coded).
- [ ] All strings i18n'd in both arbs; no Chinese string literals outside `*.arb`.
- [ ] Tests (inject an in-memory `SettingsRepository` fake + stub `packageInfoProvider` via provider
      overrides): store round-trip (load defaults, setDnd/setLocaleOverride persist + re-read), and a
      widget test that overriding the locale to `zh` renders a Chinese label (reuse the existing
      `widget_test.dart` zh pattern).
- [ ] `dart format .` / `flutter analyze` / `flutter test` all clean.

## Notes / hints
- `runApp` already initializes the widgets binding, so `SharedPreferences.getInstance()` works without
  extra setup; the controller's lazy `_load()` keeps startup non-blocking.
- gen_l10n regenerates `lib/l10n/generated/` from the arbs on `flutter pub get` (that dir is
  gitignored) — run pub get after editing the arbs, before analyze/test.
- Keep the store behind `settingsControllerProvider` so task-07 / future re-engagement can read DND
  without touching shared_preferences directly.
