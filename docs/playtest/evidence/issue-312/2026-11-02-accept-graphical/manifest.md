# Playtest run — issue #312 (desktop keyboard bindings B4–B10, B14–B20, B24–B30)

- **Issue:** #312 Desktop keyboard bindings B4–B10, B14–B20, B24–B30 (Enter/Space, Escape, arrows, P) (`type:task`, Wave 2, parent #96)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `56b973f` (`main`; the issue's deliverable tree is `fcd899e`, and `git diff fcd899e 56b973f -- game/ ':!game/test'` is empty), Godot 4.7.2.stable, session `issue-312-accept-312-graphical`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (Xvfb, 1100×844 desktop)
- **Level:** UX — `J-play-puzzle`, `J-leave-resume`, `J-gallery-reset`, `J-settings`, and `IN` / `UI-puzzle` mark input
- **Mockups:** not engaged — input/binding work; the screen mockups are already approved.

## Scope

The deliverables add desktop keyboard routes over the existing screens: `IN.confirm` /
`IN.activate` (B4), `IN.cancel` / `IN.back` (B5), `IN.point` focus traversal (B6), and
`IN.pause` (B10), with the `macOS` B14–B20 and `Linux` B24–B30 mirrors using the same code
path. Intersecting the `full` coverage set with the IDs those routes can touch gives
`J-play-puzzle` (open from gallery, back from result), `J-leave-resume` (Escape leave and
reopen), `J-gallery-reset` (`EX.confirm` by Enter/Space/Escape), `J-settings` (focus,
activate, Back), and `IN` / `UI-puzzle` mark input (the new `_input` path must not disturb
marks, tools, or drag). No design story is reachable from this change.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `J-play-puzzle` / `PTU-play-puzzle` S1–S4, P1–P2 | **pass** | Enter opens the focused tile; arrows follow C1 C6 C3; F selects Fill; the last fill solves; Enter on result C1 returns to the gallery; the tile reads Done |
| `J-leave-resume` / `PTU-leave-resume` S1–S3, P1–P2 | **pass** | Escape leaves through `UI-puzzle.C1`; the tile offers Reset; reopen restores the `(1,1)` fill and elapsed resumes at 2 s |
| `J-gallery-reset` / `PTU-gallery-reset` S1–S3, P1–P2 | **pass** | C2 shows `EX.confirm`; Escape cancels with a byte-identical progress document; Enter confirms and clears the record |
| `J-settings` / `PTU-settings` S1–S3, P1–P2 | **pass** | Space flips haptics once; arrows walk C1 → C2 → C3; Escape returns to the gallery; the changed value is shown on reopen |
| `IN` / `UI-puzzle` / `PTU-mark-input` S2–S5, P1–P5 | **pass** | Tap fill/clear, complement cross, and a three-cell drag all match; P pauses into settings with no mark or tool change; Escape resumes |
| `PTU-play-puzzle` F1–F2, `PTU-leave-resume` F1–F2, `PTU-gallery-reset` F1–F2, `PTU-settings` F1–F2, `PTU-mark-input` F1–F5 | **not observed** | No stuck screen, lost mark, wiped record, failed toggle, or drag mismatch |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-gallery-focus-first-tile.png) | Gallery at start: focus on the first tile C1 |
| [`01`](screenshots/01-settings-keyboard-focus-haptics.png) | `PTU-settings` S1: settings open, focus on C1 Haptics |
| [`02`](screenshots/02-settings-haptics-toggled.png) | S2: haptics flipped once (On → Off) |
| [`03`](screenshots/03-settings-reopened-stuck.png) | P2: reopened settings still shows Off |
| [`04`](screenshots/04-puzzle-keyboard-focus-leave.png) | `PTU-play-puzzle` S2: Ready, focus on C1 Leave (one fill from solve) |
| [`05`](screenshots/05-puzzle-keyboard-focus-settings.png) | S2 / B6: Down moves focus to C6 Settings |
| [`06`](screenshots/06-result-default-focus-back.png) | S4: result at Default with C1 focused |
| [`07`](screenshots/07-gallery-after-keyboard-play.png) | P1–P2: gallery after the keyboard round trip; pack-001 reads Done |
| [`08`](screenshots/08-leave-resume-board-marked.png) | `PTU-leave-resume` S1: `(1,1)` filled, elapsed 2 s |
| [`09`](screenshots/09-gallery-in-progress-after-escape.png) | S2 / B5: gallery after Escape leave; the tile offers Reset |
| [`10`](screenshots/10-leave-resume-restored.png) | S3 / P1–P2: reopened board with the mark restored and elapsed resumed |
| [`11`](screenshots/11-mark-input-fill.png) | `PTU-mark-input` S2 / P1: `(1,4)` filled by a tap |
| [`12`](screenshots/12-mark-input-cleared.png) | S3 / P2: second tap clears `(1,4)` |
| [`13`](screenshots/13-mark-input-complement-cross.png) | S4 / P3: secondary click makes `(1,3)` a cross |
| [`14`](screenshots/14-mark-input-drag-crosses.png) | S5 / P4: Cross tool, three cells crossed by one drag |
| [`15`](screenshots/15-mark-input-paused-by-p.png) | B10: P from the open puzzle opens settings; grid and tool unchanged |
| [`16`](screenshots/16-gallery-reset-confirm.png) | `PTU-gallery-reset` S1: C2 shows `EX.confirm` |
| [`17`](screenshots/17-gallery-after-escape-cancel.png) | S2 / P1 / B5: Escape cancels; the tile is unchanged |
| [`18`](screenshots/18-gallery-after-enter-confirm.png) | S3 / P2 / B4: Enter confirms; the tile reads Not started |

## Paths

| Artifact | Path |
|----------|------|
| Notes and per-check judgement | [`notes.md`](notes.md) |
| Probe (removed from `game/` after the run) | [`probe/probe_accept_312.gd`](probe/probe_accept_312.gd) |
| Capture console, 86/86 checks, exit 0, with `session-start` / `session-end` | [`logs/probe-graphical.log`](logs/probe-graphical.log) |

## Quality evaluator

Deterministic: covered by [`docs/quality/evidence/issue-312/2026-11-02-verify/manifest.md`](../../../../quality/evidence/issue-312/2026-11-02-verify/manifest.md)
(`frame-time`, `hitch-bound`, `response-delay`, `crash-free` all pass; deliverable `fcd899e`).
`llm-judge`: N/A — every rubric axis is deterministic and the domain axis list is empty.
