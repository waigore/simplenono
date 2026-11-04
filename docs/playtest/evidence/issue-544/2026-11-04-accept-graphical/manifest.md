# Playtest run — issue #544 (graphical acceptance, Android emulator)

- **Issue:** #544 Android system navigation chrome: lock whether the OS nav bar stays visible, then set the export presets (`type:task`, `priority:high`)
- **Run id:** `2026-11-04-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-04
- **Build / session id:** `android-debug/401725fd37b6` — CI-built debug APK (release `android-debug/401725fd37b657b8590e743fc4e9f41e85cded12`, PR #568 head `401725f`; the branch tree equals `main` because every conflict was resolved in favor of `main`), Godot 4.7.2.stable, session is the APK default (`--session-id` cannot be passed to an Android launch, so `TEL.3` is the engine default)
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical — **Android emulator** (AVD `Medium_Phone_API_36.1`, API 36.1, 1080×2400 at ~420 dpi, gesture navigation), APK `com.simplenono.debug` (`adb install -r` of the CI artifact), orientation locked portrait by the build
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-544-2026-11-04-accept-graphical>

## Scope

The locked decision #544 ratifies: the Android OS status bar and navigation / gesture band stay
visible, drawn by the OS outside the game surface. Verification's deterministic record
(`docs/quality/evidence/issue-544/2026-11-04-verify/manifest.md`, deliverable `37f469b`) explicitly
left the judged OS-chrome behaviour — playtest `S6` / `P4` / `F4` — to acceptance on a device or
emulator. This run is that device-class evidence.

Only `PTU-leave-resume` (`S6`, `P4`, `F4`) is in scope; every other UX protocol was untouched by
this issue's deliverable (spec capture, preset comments, one GUT data test).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-leave-resume` `S6` | **pass** | from an in-progress attempt on `UI-puzzle` (portrait; orientation locked, so the landscape clause is the not-allowed case), the system gesture-bar swipe left the app to the launcher; relaunch and `UI-gallery.C1` reopen restored the attempt |
| `P4` (chrome visible / usable on all four screens) | **pass** | status bar and gesture pill visible and outside the game surface on `UI-puzzle`, `UI-gallery`, `UI-settings`, and `UI-result`; no screen covers or hides them |
| `P4` (gesture leaves; attempt still in progress on return) | **pass** | launcher shown after the leave; cold relaunch gallery reads `10×10 · #000` **In progress**; reopen restores the filled cell `(3,3)` and elapsed resumes at 1:59 from the committed value (not 0) |
| `F4` (chrome hidden / unreachable) | **not observed** | chrome stayed visible on every judged screen |

## Judged states (wiki media, this build)

| Screenshot | Judged state |
|------------|--------------|
| `01-gallery-chrome-visible` | `UI-gallery`, OS status bar and gesture pill outside the game surface |
| `02-puzzle-open-chrome` | `UI-puzzle` open (`#000`, elapsed 0:09) with chrome |
| `03-before-leave-one-mark-chrome` | cell `(3,3)` (a `pack-000` solution cell) filled with the Fill tool; attempt in progress |
| `04-home-after-gesture-leave` | launcher after the gesture-bar leave |
| `05-warm-restore-puzzle-ticking` | first relaunch restored the warm task into `UI-puzzle`, elapsed still counting (2:15) |
| `06-cold-relaunch-gallery-in-progress` | cold relaunch: gallery tile `In progress` |
| `07-reopen-mark-restored` | after `UI-gallery.C1`: mark restored, elapsed 1:59 resuming |
| `08-result-chrome-visible` | `UI-result` after solving `#000` exactly from `game/data/pack.json` |
| `09-settings-chrome-orientation-locked` | `UI-settings` chrome + `Orientation Locked · no tilt · Portrait` |
| `10-final-gallery-completed` | `Completed 1 / 200`, `#000` `Done · Best 7:02` |

## Paths

| Artifact | Path |
|----------|------|
| Notes | [`notes.md`](notes.md) |
| Screenshots and session log | wiki page, `playtest/issue-544/2026-11-04-accept-graphical/` (`screenshots/`, `logs/logcat-judged-window.txt`) |

## Deterministic quality evaluator

**Cited, not re-run** (acceptance never runs that mode):
[`docs/quality/evidence/issue-544/2026-11-04-verify/manifest.md`](../../../../quality/evidence/issue-544/2026-11-04-verify/manifest.md)
covers the deliverable commit `37f469b` — `frame-time`, `hitch-bound`, `transition-latency`,
`response-delay`, `crash-free` all pass. `llm-judge` is N/A (every rubric axis is `deterministic`,
domain axes empty).
