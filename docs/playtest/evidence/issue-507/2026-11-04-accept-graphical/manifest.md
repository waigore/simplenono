# Playtest run — issue #507 (graphical acceptance)

- **Issue:** #507 Result screen: Back to gallery label invisible until clicked (`type:defect`, `priority:high`)
- **Run id:** `2026-11-04-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-04
- **Build / session id:** `main@4953c48` (PR [#510](https://github.com/waigore/simplenono/pull/510) squash `b104b65`, evidence PR [#512](https://github.com/waigore/simplenono/pull/512)), Godot 4.7.2.stable, session `issue-507-accept`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (900×1200),
  Vulkan Forward+ on llvmpipe under Xvfb, Linux x86_64, fresh `user://` (isolated `HOME`)
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-507-2026-11-04-accept-graphical>

## Scope

PR #510 changes two theme color overrides on `ResultScreen._style_back_button()`
(`game/presentation/result.gd`): `font_focus_color` and `font_hover_pressed_color` become
Ink (`PAL.K1`). Nothing else in `game/` moves; `git diff b104b65 4953c48 -- game/` is empty.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| `PTU-play-puzzle` S3–S4, P1–P2 (`J-play-puzzle`, `UI-result`) | Solve → result morph → C1 `copy.back` readable → Back → gallery is the whole reach of the change |
| `PTU-mark-input` P1–P3 (`US1.6`, `US1.6b`, `US1.7`) | A puzzle still takes marks after the change; the probe drives the shipped screens, so the neighbouring input layer is exercised |

Out of scope: `PTD-ready-and-marks`, `PTD-solve-and-pb`, `PTD-crosses-and-fills`, `PTD-pack-finished`,
`PTU-leave-resume`, `PTU-gallery-reset`, `PTU-settings` — no rule, gallery, settings, or persistence
code is in the diff.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-play-puzzle` S3 / P1 | **pass** | the shipped fills solve `pack-003` and the app leaves for `UI-result` |
| `PTU-play-puzzle` S4 | **pass** | morph reaches Default, C1 drawn, `copy.back` = "Back to gallery", shell focuses C1, a real tap returns to the gallery |
| `PTU-play-puzzle` P2 | **pass** | tile `#003` reads Done after return |
| `PTU-mark-input` P1 | **pass** | a real tap fills a clear cell (`pack-004`) |
| `PTU-mark-input` P2 | **pass** | a second tap clears it |
| `PTU-mark-input` P3 | **pass** | complement (secondary click) on a clear cell crosses it |

Capture: **20 checks `capture: PASS`, 0 `capture: FAIL`**, final line
`capture: RESULT pass (5 shots, 0 checks failed)`, exit 0 —
[wiki `logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-507-2026-11-04-accept-graphical).

## The defect state, judged graphically

The reported symptom is mobile: C1's label is invisible until tapped. On a touch device the
shell focuses C1 when the morph ends, so the focused idle state **is** what the player sees,
and Godot draws it with `font_focus_color`. The probe samples every pixel of C1's label box
in that state, before any interaction:

| Reading (shot `01`) | Value | Meaning |
|---------------------|-------|---------|
| darkest drawn pixel | `(0.1059, 0.1569, 0.2)` | `PAL.K1` Ink (the palette's Ink color) |
| button fill | `(0.9569, 0.9686, 0.9725)` | Paper, within the probe's 0.06 bar of `PAL.PAPER` |
| label box | 30,552 px | inside the frame |

Before PR #510 the same focus color was the engine's near-white default. Verification showed
this on the pre-fix tree (`7070819`): the added unit test fails on `font_focus_color`, so the
fix closes the drawn gap the defect names.

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-507/2026-11-04-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-result-back-label-focused.png` | `PTU-play-puzzle` S4 | C1 after both morph stages, focused, never touched: "Back to gallery" in Ink on Paper |
| `screenshots/03-gallery-after-back.png` | `PTU-play-puzzle` S4 / P2 | Gallery after a real tap on C1; `#003` Done |
| `screenshots/04-puzzle-mark-fill.png` | `PTU-mark-input` P1 | `pack-004`: a real tap filled a clear cell |
| `screenshots/05-puzzle-mark-cleared.png` | `PTU-mark-input` P2 | the same cell after a second tap: clear |
| `screenshots/06-puzzle-mark-cross.png` | `PTU-mark-input` P3 | complement on a clear cell: crossed |

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, blockers | [`notes.md`](notes.md) |
| Probe (copied to `game/` for the run, removed after) | [`probe/probe_accept_507.gd`](probe/probe_accept_507.gd) |
| Capture console (20 PASS, final RESULT) | wiki page, `logs/capture.log` |
| `DBG.2` state dump | wiki page, `logs/state-pack-003.json` |
| Screenshots (5, graphical run of this build) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic`: **cited, not re-run.** Verification wrote a passing record at the deliverable
commit `b104b65` — [`../../../../quality/evidence/issue-507/2026-11-04-verify/manifest.md`](../../../../quality/evidence/issue-507/2026-11-04-verify/manifest.md).
The record's observation source is the `navigate` / `solve-reset` protocols; this tree adds only
the evidence commit #512, so its `game/` tree is the measured one. `transition-latency`
433.5 ms ≤ 500 ms and `crash-free` (open, solve, reset, back) → pass; no row is `fail` or `blocked`.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Notes

- **Display.** This host has no monitor; the graphical run used Xvfb (`xvfb-run`, 1000×1300×24)
  with Vulkan Forward+ on llvmpipe. The shipped `shell.tscn` ran at 900×1200 as the app does on a
  phone, and every shot comes from `root.get_texture()`, not from the harness.
- **Touch path.** The fix's other half (`font_hover_pressed_color`) is the touch release state.
  It is covered by the unit test at `b104b65`; this run drives mouse events, so the release state
  is not separately shot. The issue's reported state (focused, untouched) is.
- The probe selects a clear cell with empty-clue auto-cross in mind; `pack-004` crosses such a
  cell the moment it is left clear, so the complement target is chosen at step time.
