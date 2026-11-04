# Notes — issue #544 acceptance playtest

Run folder: `2026-11-04-accept-graphical`. Wiki page:
<https://github.com/waigore/simplenono/wiki/Playtest-issue-544-2026-11-04-accept-graphical>
(all screenshots and `logs/logcat-judged-window.txt`).

## What this run judged

`PTU-leave-resume` `S6` / `P4` / `F4` — the Android OS-chrome behaviour the #544 verification
record handed to acceptance. One continuous Android-emulator session (AVD `Medium_Phone_API_36.1`,
1080×2400, gesture navigation, API 36.1), APK `com.simplenono.debug` from release
`android-debug/401725fd37b657b8590e743fc4e9f41e85cded12` (PR #568; branch tree resolved in favor of
`main`, so the built tree is `main`'s), fresh install, no prior app data.

## Drive

- Protocol `S6`: gallery (`01`) → `UI-gallery.C1` opens `10×10 · #000` (`02`, get-set-ready passing,
  elapsed 0:09) → filled cell `(3,3)` with the Fill tool (`03`, verified by frame pixel check:
  the cell patch is Ink) → **left the app with the system navigation gesture** (swipe up from the
  bottom): `04` is the launcher; `ActivityTaskManager` lines in the logcat show the game task
  paused. The app left on the OS gesture — no in-app control used, which is exactly what decision 1
  requires.
- First relaunch restored the warm task into `UI-puzzle`, elapsed still counting (`05`, 2:15).
- For a stronger relaunch leg, `am force-stop` then `am start`: cold start lands on `UI-gallery`
  with tile `#000` reading **In progress** (`06`), then `UI-gallery.C1` reopens the tile: the
  filled cell `(3,3)` is still filled and the elapsed resumed from the committed value (**1:59**,
  same order of magnitude, not reset — `07`).
- `P4`'s screen checklist: chrome on `UI-puzzle` (`02`, `03`), `UI-gallery` (`01`, `06`),
  `UI-settings` (`09`), `UI-result` (`08`). To reach `UI-result`, the puzzle was driven to solve:
  the remaining `pack-000` solution cells were filled exactly from `game/data/pack.json`
  (`solution-fills`), each landing verified by frame pixels, and the solve transition ran
  automatically; `#000` ends `Done · Best 7:02`, `Completed 1 / 200` (`10`).
- `F4` was never observed — no screen hid or made unreachable the status bar / gesture band.

## Observations

- **No `DBG.*` seams on the device build.** The shipped APK boots with the seams flag off and an
  Android launch cannot pass `--debug-seams`, so `TEL.1`–`TEL.5` events are not in the log; the
  judged states come from the display frames themselves, and the logcat excerpt covers the judged
  window (Godot app lines + `ActivityTaskManager` / launcher beats). The wall clock and the
  on-screen elapsed together pin the leave → resume beats.
- **Resumed-to-puzzle vs resumed-to-gallery.** The protocol says "relaunch and reopen the tile with
  `UI-gallery.C1`". A warm task relaunch restores straight into `UI-puzzle` (`05`) — the OS task
  is relaunchable either way; the cold relaunch leg exercises the gallery path the protocol names.
  Both keep the attempt in progress; neither resets elapsed.
- **Elapsed keeps ticking while the app is backgrounded** (`2:15` at background, `1:59` restored
  after ~3 min of being dead — resumed from the last commit). P4 does not judge background
  count-up; noted as a non-blocking observation.
- **Orientation.** `UI-settings` shows `Orientation Locked · no tilt · Portrait`, and forcing the
  system `user_rotation` did not rotate the game frame, so `S6`'s "where the OS allows it, locked
  landscape" clause has no allowed landscape case on this build. Portrait is the judged
  orientation.
- **No defect filed.** The judged behaviour matches the locked decision and the captured specs;
  nothing failed for a game or interface reason.

## What was NOT checked

- Physical-device confirmation (emulator only) — flag for a future release-input check, #502 owns
  the signed release package surface.
- Other UX protocols (`PTU-play-puzzle` S1–S5 legs, `gallery-reset`, `mark-input`, `settings`
  journeys) — untouched by #544's deliverable.
