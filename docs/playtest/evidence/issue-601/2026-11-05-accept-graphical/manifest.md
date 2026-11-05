# Playtest run — issue #601 (graphical acceptance, puzzle chrome labels)

- **Issue:** #601 Puzzle Leave button: label invisible until clicked (`type:defect`,
  `status:pending-acceptance`, `priority:high`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** the deliverable commit `ed91db1` (PR #607 squash), session
  `issue-601-accept`, Godot 4.7.2.stable, Vulkan Forward+ on llvmpipe under Xvfb
  (`xvfb-run`, 1000×1300×24), app frame 900×1200, Linux x86_64, fresh `user://`.
  `git diff ed91db1 HEAD -- game/presentation/puzzle.gd` is empty on `main`, and nothing
  after #607 touches the puzzle chrome.
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-601-2026-11-05-accept-graphical>

## Scope

The deliverable is a theme-color override on `UI-puzzle`'s chrome and tool buttons
(`PuzzleScreen._style_chrome_button()` / `_style_tool_buttons()`): `font_focus_color`
becomes Ink (`PAL.K1`), plus `font_hover_pressed_color` on C1/C6. The reported symptom is
C1's `copy.leave` label invisible until pressed, because the shell focuses C1 when the
puzzle is shown and Godot draws a focused idle button with `font_focus_color`.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-leave-resume`](../../../../../specs/playtest/ux/leave-resume.md) S1–S3 / P1–P2 | Its C1 is the control under test: Leave shows, leaves, leaves the tile In progress, reopens with marks restored |
| [`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md) S1–S4 / P1, P3 | The same screen's beat-blocked mark, mark transitions, and C6 pause/resume |
| [`PTU-mark-input`](../../../../../specs/playtest/ux/mark-input.md) P1–P3 | Fill, clear, and complement on the screen whose styling changed |
| `PTU-play-puzzle` S4 | Out of scope: the result screen is not in the diff (#507 owns its C1) |

Out of scope: `PTD-solve-and-pb`, `PTD-crosses-and-fills`, `PTD-pack-finished`,
`PTU-play-puzzle` (beyond the shared open path), `PTU-gallery-*`, `PTU-settings` — no rule,
gallery, settings, result, or persistence code is in the diff.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-leave-resume` S1 | **pass** | `pack-004` opens; C1 drawn, text `Leave`, focused by the shell, label Ink `(0.1059, 0.1569, 0.2)` on Paper `(0.9569, 0.9686, 0.9725)` before any press — in get-set-ready and again once ready |
| `PTD-ready-and-marks` P1 | **pass** | a mark during get-set-ready left the tried cell clear; after ready fill → clear → cross all applied |
| `PTD-ready-and-marks` P3 | **pass** | C6 paused the attempt, elapsed frozen at 1 for 1.5 s, marks blocked while paused, allowed again after Back |
| `PTU-mark-input` P1–P3 | **pass** | a real tap fills the clear cell (neighbour untouched), a second tap clears it, complement crosses it |
| `UI-puzzle` C1/C6/C3–C5 labels | **pass** | every label Ink on Paper with no interaction; selected tool C4 is Paper on Ink |
| `PTU-leave-resume` S2 / P1–P2 | **pass** | C1 press → gallery, tile reads `In progress`; reopen through the tile runs get-set-ready and restores the cross and elapsed (2 s, ticking) |

Capture: `capture: RESULT pass (8 shots, 0 checks failed)`, exit 0 —
[wiki `logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-601-2026-11-05-accept-graphical).

**Control (pre-fix tree `6ec4077`, one step before the deliverable).** The same
focused-idle reading draws C1's label at `(0.949, 0.949, 0.949)` on Paper — the engine's
near-white `font_focus_color` default, the invisible "Leave" the defect reports — while
the post-fix tree reads Ink for the same state. So the pass is not a blind spot of the
probe.

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-601/2026-11-05-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-puzzle-leave-get-set-ready.png` | `PTU-leave-resume` S1 | C1 focused in the beat, never touched: "Leave" in Ink on Paper |
| `screenshots/02-puzzle-leave-ready.png` | `PTU-leave-resume` S1 | C1 focused once ready, never touched |
| `screenshots/03-puzzle-settings-label-focused.png` | `UI-puzzle` C6 | "Settings" focused, Ink |
| `screenshots/04-puzzle-tool-labels-focused.png` | `UI-puzzle` C3–C5 | tool labels, Cross selected (Paper on Ink) |
| `screenshots/05-puzzle-marks-ready.png` | `PTU-mark-input` P1–P3 | board after fill, clear, complement |
| `screenshots/06-settings-paused.png` | `PTD-ready-and-marks` S4 | `UI-settings` while the attempt is paused |
| `screenshots/07-gallery-in-progress.png` | `PTU-leave-resume` S2 | tile reading In progress after C1 |
| `screenshots/08-puzzle-reopened-ready.png` | `PTU-leave-resume` P1–P2 | reopened board: cross restored, elapsed resumed |
| `screenshots/control-01-prefix-leave-focused.png` | control | pre-fix tree: focused C1 label near-white on Paper |

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, harness caveats | [`notes.md`](notes.md) |
| Probe (copied to `game/` for the run, removed after) | [`probe/probe_accept_601.gd`](probe/probe_accept_601.gd) |
| Capture console (RESULT pass) | wiki page, `logs/capture.log` |
| Pre-fix control console and shot | wiki page, `logs/control-prefix-capture.log`, `screenshots/control-01-prefix-leave-focused.png` |
| `DBG.2` state dump | wiki page, `logs/state-pack-004.json` |
| Screenshots (8, graphical run of this build) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic` record cited: [`docs/quality/evidence/issue-601/2026-11-05-verify/manifest.md`](../../../../quality/evidence/issue-601/2026-11-05-verify/manifest.md)
— recorded on exactly this `game/` tree (`ed91db1`); `response-delay` 28.7 ms ≤ 500 ms and
`crash-free` pass, no `fail` or `blocked` row.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Notes

- **Frames.** Mobile and desktop share this scene and this styling path; the colour is
  pinned on the shared buttons, so one run at the app frame covers both. No layout, framing,
  or copy change is in the diff.
- **Touch release.** `font_hover_pressed_color` (C1/C6 under a held finger) is pinned in the
  same change and covered by the unit test at `ed91db1`; this run drives a pointer press,
  and the judged state is the focused-untouched one the defect reports.
- **Pointer vs programmatic legs.** The settings Back leg and the gallery tile C1 leg use
  the shell's routing entry points: at 900×1200 the settings page scrolls C3 below the fold
  and the gallery needs a drag to reach a below-fold tile, and neither scroll is this
  issue's to judge (`PTU-gallery-layout` owns tile C1). Every other leg is a real pointer
  press.
