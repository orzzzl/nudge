# Device-verify playbook

How to manually verify Nudge on a real emulator/simulator — the step host unit tests **cannot**
cover (native libs, notifications, real navigation, locale switch, on-device rendering). Host tests
run on the dev machine's sqlite3 and a fake clock; they prove logic, not that the app actually works
on a device. This playbook is self-contained: follow it top-to-bottom without prior context.

> **Who runs this:** the human, Claude, or Codex. It's read-only verification (plus throwaway test
> data on the emulator) — no repo changes. Record results in a PR comment or `tasks/` note; do not
> commit screenshots.

---

## 0. Toolchain (already installed on this machine)

| Tool | Path |
|------|------|
| Flutter 3.44 | `~/development/flutter/bin` |
| JDK 21 | `~/development/jdk` |
| Android SDK | `~/Library/Android/sdk` (AVD `nudge_test`, API 36) |
| `adb` | `~/Library/Android/sdk/platform-tools/adb` |
| Xcode + iOS 26.5 sim | iPhone 17 Pro |
| `gh` | `~/.local/bin/gh` |

Put the tools on PATH for the session (zsh):

```bash
export PATH="$HOME/development/flutter/bin:$HOME/Library/Android/sdk/platform-tools:$HOME/.local/bin:$PATH"
export JAVA_HOME="$HOME/development/jdk"
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
```

Sanity check: `flutter --version` and `adb --version` should both print.

---

## 1. Pick a target & boot it

**Android (primary — required for the notification path):**

```bash
# list AVDs
~/Library/Android/sdk/emulator/emulator -list-avds        # expect: nudge_test
# boot it (backgrounded)
~/Library/Android/sdk/emulator/emulator -avd nudge_test -no-snapshot-save &
# wait until fully booted
adb wait-for-device shell 'while [[ "$(getprop sys.boot_completed)" != "1" ]]; do sleep 1; done'
adb devices                                               # expect: emulator-5554  device
```

**iOS (secondary — UI/locale/rendering only; local notifications behave differently on the sim):**

```bash
xcrun simctl boot "iPhone 17 Pro" 2>/dev/null || true
open -a Simulator
```

---

## 2. Build, install, run

From the repo root (`~/nudge`):

```bash
flutter pub get                         # regenerates l10n + pulls deps (do this first, always)
flutter run -d emulator-5554            # Android
# or:  flutter run -d "iPhone 17 Pro"   # iOS
```

Leave `flutter run` attached in one terminal — you'll use `r` (hot reload) / `R` (hot restart) /
`q` (quit) there. Drive the UI and capture screens from a **second** terminal with `adb`.

If the app crashes on first DB touch on Android, suspect the native-libs trap (see Gotchas).

---

## 3. Driving primitives (Android)

Work **screenshot-first**: capture, look at where things actually are, then tap by coordinate. Don't
hardcode coordinates blind — layouts shift with locale and device.

```bash
# screenshot to a file, then open/read it
adb exec-out screencap -p > /tmp/nudge.png        # then Read /tmp/nudge.png

# tap at x,y (pixels from top-left)
adb shell input tap 540 1200

# type into the focused field (no spaces; use %s for a space, or keyevent)
adb shell input text 'Focus'
adb shell input keyevent KEYCODE_SPACE
adb shell input text 'block'

# dump the view tree to resolve a widget's bounds when a tap keeps missing
adb shell uiautomator dump /sdcard/ui.xml && adb pull /sdcard/ui.xml /tmp/ui.xml   # then read /tmp/ui.xml

# back button / home
adb shell input keyevent KEYCODE_BACK
```

Loop: **screencap → Read the PNG → decide next tap → tap → screencap again.** One action per
screenshot when in doubt.

---

## 4. The clock trick (needed for time-up / notifications)

The shortest plan duration is **30 minutes** (chips: 30/60/90/120), so you can't wait out a block.
Advance the emulator's clock instead:

```bash
adb root                                            # restart adbd as root (emulator only)
# set date/time: format MMDDhhmm[[CC]YY][.ss]  (month day hour min . sec)
# e.g. jump to 2030-01-01 09:00:00:
adb shell 'su 0 date 010109002030.00'
adb shell 'su 0 toybox date'                        # confirm the new time
```

> ⚠️ **Critical nuance — what the clock trick does and doesn't fire:**
> - ✅ **Scheduled notifications** (`zonedSchedule` at `endAt`) — advancing wall-clock past `endAt`
>   makes the OS fire the alarm. This is the task-07 / task-08 notification path.
> - ✅ **Restore-past-end in-app prompt** — on app launch, `_armCheckInTimer` sees `endAt` is already
>   in the past (`delay <= 0`) and prompts immediately. Trigger it by advancing the clock **then
>   hot-restarting** (`R`) or relaunching the app.
> - ❌ **The live in-app countdown `Timer`** — a Dart `Timer` fires on *elapsed real time*, not
>   wall-clock, so moving the clock does **not** make a running app's auto-prompt fire early. To see
>   that exact path live you'd have to wait the real 30 min; in practice verify it via the
>   restore-past-end path above (same `_promptCheckIn` code) and trust the unit tests for the live timer.

Set the clock **back to network time** when done: `adb shell 'su 0 date $(date +%m%d%H%M%Y.%S)'` or
just `adb shell settings put global auto_time 1` and toggle airplane mode, or simply cold-boot the AVD.

---

## 5. Feature checklists (the three unverified since task 07)

### Task 08 — auto check-in at time-up
1. **Notification tap (warm):** On the Chat tab, type a task name, leave duration at 30, tap the
   start/确定 button → a countdown capsule appears. Advance the clock past `endAt` (§4) → the
   notification should post. Pull down the shade (`adb shell cmd statusbar expand-notifications`),
   screenshot, tap the Nudge notification → app comes forward and the **check-in sheet opens for that
   plan** (title matches).
2. **Notification tap (cold start):** Repeat, but `q` the app (or swipe it from recents) before tapping
   the notification. Tapping it should cold-launch the app and still open the correct check-in sheet.
3. **Restore-past-end in-app:** Create a plan, advance the clock past `endAt`, then hot-restart (`R`
   in the `flutter run` terminal). On launch the check-in sheet should **auto-open once**.
4. **Debounce:** Dismiss the sheet (swipe down / tap outside) without choosing → it must **not**
   immediately re-open; the capsule's manual check-in button still works.
5. **Pick a status** (✅ done / 🍃 partial / 😴 missed) → sheet closes, a result bubble appears, the
   capsule clears back to the composer.

### Task 09 — 团团 mascot mood
The mascot is a small circular badge (emoji + mood-tinted ring): happy 🌳 / neutral 🌱 / sad 🥀.
1. **Sad / neutral / happy** depend on this week's stats (`plannedMinutes==0` → sad; `streak>=3` or
   `completion>=60%` → happy; else neutral). On a fresh emulator with no plans, the mascot should be
   **sad** (🥀) in both the chat AI-bubble avatar and the Stats-tab header.
2. Create a plan and check it in as ✅ done → reflects in stats; the mascot should move toward
   **happy/neutral** (one done block this week = 100% completion → happy). Screenshot both the chat
   avatar and the Stats header and confirm they show the **same** mood and it renders cleanly at both
   sizes (small in chat, large in stats — no clipping/overflow).

### Task 10 — settings + 勿扰
1. Tap the ⚙️ in the top app bar (visible on both Chat and Stats) → the Settings screen pushes in
   with a back button.
2. **Language override:** tap **中文** → the whole UI switches to Chinese immediately (tab labels,
   composer hint, etc.). Tap **English** → switches back. Tap **System** → follows the device.
3. **Persistence:** set 中文, fully quit (`q`) and relaunch (`flutter run` again, or cold-launch) →
   the app should come back in Chinese.
4. **DND:** toggle the 勿扰 switch on, quit + relaunch → it should still be on (stored; it doesn't
   gate the per-plan reminder yet — that's by design).
5. **About:** shows the app name + a real version string (e.g. from `pubspec.yaml`), not a placeholder.

---

## 6. Capturing evidence

For each checked item, keep a screenshot named by step (e.g. `08-2-coldstart.png`) in `/tmp`, Read it
to confirm, and summarize pass/fail in the PR comment or a `tasks/` note. **Do not commit screenshots
or test data.** Example results block:

```
Device-verify (Android emulator nudge_test, API 36):
- 08 notification tap (warm): PASS — sheet opened for "Focus block"
- 08 cold start: PASS
- 08 restore-past-end: PASS — auto-opened once on relaunch
- 08 dismiss debounce: PASS — did not re-open
- 09 mascot sad→happy: PASS — chat + stats agree
- 10 language zh live + persist: PASS
- 10 DND persist: PASS
- 10 About version: PASS (1.0.0+1)
```

---

## 7. Teardown
- `q` in the `flutter run` terminal to stop the app.
- Reset the clock (§4) or cold-boot the AVD so it isn't stuck in the future.
- Optionally wipe test data: `adb shell pm clear com.nudge.app`, or uninstall:
  `adb uninstall com.nudge.app`. (applicationId is `com.nudge.app`, set in
  `android/app/build.gradle.kts`.)
- Kill the emulator: `adb -s emulator-5554 emu kill`.

---

## 8. Gotchas (learned the hard way)
- **Native-lib trap:** host tests use the dev machine's sqlite3, so they miss on-device native-lib
  breakage. `sqlite3_flutter_libs 0.6.0+eol` shipped no `libsqlite3.so` and crashed on first DB touch
  (fixed → `^0.5.42`). Always device-verify after a DB/plugin/dep change.
- **Dart `Timer` ≠ wall clock** — see §4. The live countdown auto-prompt can't be sped up by the clock
  trick; verify via the restore-past-end path.
- **GitHub push rejected with a stale token:** Xcode's global gitconfig puts `osxkeychain` first. Run
  `printf "protocol=https\nhost=github.com\n" | git credential-osxkeychain erase`.
- **`flutter pub get` first**, every time — gen_l10n's `lib/l10n/generated/` is gitignored and is
  regenerated by pub get; analyze/run will fail on a fresh checkout without it.
- **Notification permission caching (task-07 follow-up):** `_requestPermissions` caches a denial for
  the session, so if you deny the runtime prompt once, reminders stay off until relaunch. Grant it on
  first launch when verifying the notification paths.
- **iOS local-notification scheduling** differs from Android and the clock trick doesn't apply the same
  way on the sim — use Android for the time-up/notification checks; use iOS for UI/locale/rendering.
