# Playtest run — issue #323 (pause leg, pause-then-quit, Android Back B37)

- **Issue:** #323 J-leave-resume pause leg, pause-then-quit story, and Android Back
  (`type:task`, Wave 2 — Complete play journey, parent #96)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `1520675` (`main`, squash of PR #340). The probe ran on
  `62fd0ec` (PR #340's merge commit); `git diff 62fd0ec 1520675` is empty, so the
  judged tree is the deliverable tree. Godot 4.7.2.stable, sessions
  `issue-323-accept-323-graphical`.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
  · graphical (Xvfb, 900×1400 phone-shaped window)
- **Level:** UX — `J-leave-resume` (`US1.1`, `US1.2`), protocol
  [`PTU-leave-resume`](../../../../../specs/playtest/ux/leave-resume.md), and
  `B37` / `US1.11`
- **Mockups:** not engaged — no screen layout changed, and
  `specs/ux/journeys/leave-resume.md` and `MC.leave-resume` are unchanged.

## Scope

The deliverables change one playable input path and the pause/restore path: the Android
Back notification now travels the existing `IN.back` route, and the pause-then-quit leg
must restore the committed attempt. Intersecting the `full` coverage set with the IDs
those changes can move gives `J-leave-resume` (`US1.1` leave-and-reopen, `US1.2`
pause-then-quit), `PTU-leave-resume` S1–S5 / P1–P3, and `B37` / `US1.11` on all four
screens. No design story is reachable from this change.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `J-leave-resume` `US1.1` / `PTU-leave-resume` S1–S3 | **pass** | open → fill + elapsed 3 → C1 leave → in-progress gallery → C1 reopen → Ready restores the mark and elapsed |
| `PTU-leave-resume` P1 | **pass** | the `(1,1)` mark is restored after reopen and Ready |
| `PTU-leave-resume` P2 | **pass** | elapsed resumes at 3, not 0; the attempt stays in progress |
| `J-leave-resume` `US1.2` / `PTU-leave-resume` S4–S5 | **pass** | C6 pause → quit while settings shows → relaunch on the gallery → reopen restores the committed mark and elapsed 3 |
| `PTU-leave-resume` P3 | **pass** | elapsed ticks again after get-set-ready and a new tap is accepted, so marks are allowed |
| `B37` / `US1.11` `UI-puzzle` | **pass** | Back leaves through C1 to the gallery; the tile stays in progress; no mark placed |
| `B37` / `US1.11` `UI-settings` | **pass** | Back goes back to the gallery when opened from it, and resumes the paused puzzle when opened from the puzzle |
| `B37` / `US1.11` `UI-result` | **pass** | Back is consumed and changes nothing while C1 is unavailable; after the morph it reaches the gallery through C1 |
| `B37` / `US1.11` `UI-gallery` | **pass** | Back changes no screen, writes nothing, and is passed to the platform unconsumed |
| `B37` `EX.confirm` | **pass** | Back is consumed; the box stays up, no screen changes, no other action fires |
| `PTU-leave-resume` F1–F3 | **not observed** | No lost mark or attempt status, no elapsed reset, no pause-then-quit restore loss |
| `SEQ pause` B2 / B3 and paused-path guard | **pass** (unit) | `test_pause_during_get_set_ready_commits_the_restored_marks_as_held`, `test_pause_with_nothing_to_persist_skips_the_commit`, `test_a_gallery_path_does_not_resume_the_paused_attempt`; see the verification GUT log below |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-gallery-start.png) | Start: `UI-gallery`, pack-000 not started |
| [`01`](screenshots/01-puzzle-before-leave.png) | S1: `(1,1)` filled and elapsed `0:03` before Leave |
| [`02`](screenshots/02-gallery-in-progress.png) | S2: gallery after Leave; pack-000 in progress |
| [`03`](screenshots/03-puzzle-resumed-ready.png) | S3 / P1 / P2: reopened board with the mark and elapsed 3 restored |
| [`04`](screenshots/04-settings-paused-before-quit.png) | S4: `UI-settings` after C6, attempt paused, before the app quits |
| [`05`](screenshots/05-relaunch-gallery-in-progress.png) | S5: relaunch starts on `UI-gallery` with pack-000 in progress |
| [`06`](screenshots/06-pause-then-quit-restored.png) | S5 / P3: after reopen and Ready, the committed mark and elapsed 3 are back |
| [`07`](screenshots/07-pause-then-quit-playing.png) | P3: elapsed ticking again and a second tap accepted |
| [`08`](screenshots/08-gallery-after-back-on-puzzle.png) | B37 puzzle: Back left to the gallery; tile in progress |
| [`09`](screenshots/09-puzzle-reopened-after-back.png) | B37 puzzle: reopened board unchanged, so Back placed no mark |
| [`10`](screenshots/10-settings-back-resumes-puzzle.png) | B37 settings: Back from paused settings resumed the puzzle, marks unchanged |
| [`11`](screenshots/11-settings-back-to-gallery.png) | B37 settings: Back from gallery settings returned to the gallery |
| [`12`](screenshots/12-gallery-back-passed-to-platform.png) | B37 gallery: Back changed no screen and was passed to the platform |
| [`13`](screenshots/13-result-back-consumed-morphing.png) | B37 result: Back during the morph is consumed and the result stays |
| [`14`](screenshots/14-result-c1-available.png) | B37 result: after the morph, C1 is available |
| [`15`](screenshots/15-gallery-after-result-back.png) | B37 result: Back through C1 returned to the gallery |
| [`16`](screenshots/16-confirm-showing.png) | B37 confirm: `EX.confirm` showing |
| [`17`](screenshots/17-confirm-after-back-no-effect.png) | B37 confirm: Back consumed; the box is byte-identical to `16` |

## Paths

| Artifact | Path |
|----------|------|
| Notes and per-step judgement | [`notes.md`](notes.md) |
| Probe (removed from `game/` after the run) | [`probe/probe_accept_323.gd`](probe/probe_accept_323.gd) |
| Phase-1 capture console, 24/24 checks, exit 0 | [`logs/probe-graphical-setup.log`](logs/probe-graphical-setup.log) |
| Phase-2 capture console, 45/45 checks, exit 0 | [`logs/probe-graphical-relaunch.log`](logs/probe-graphical-relaunch.log) |
| Pause state carried from S4 to S5 | [`logs/phase-state.json`](logs/phase-state.json) |

## Quality evaluator

Deterministic: covered by
[`docs/quality/evidence/issue-323/2026-11-02-verify/manifest.md`](../../../../quality/evidence/issue-323/2026-11-02-verify/manifest.md)
(`frame-time`, `hitch-bound`, `transition-latency`, `response-delay`, `crash-free`,
`save-survives` all pass; deliverable `1520675`).
`llm-judge`: N/A — every rubric axis is deterministic and the domain axis list is empty.
