# Playtest run — issue #644 (graphical acceptance, puzzle elapsed timer Ink)

- **Issue:** #644 Puzzle chrome: elapsed timer not visibly shown (Ink on Paper)
  (`type:defect`, `status:pending-acceptance`, `priority:normal`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** the deliverable commit `d356b1fc` (PR #655 squash on `main`),
  session `issue-644-accept`, Godot 4.7.2.stable, Metal 4.0 on Apple M5, app frame
  900×1200, macOS arm64, fresh `user://`. `game/presentation/puzzle.gd` at HEAD is the
  shipped tree from #655; the pre-fix control uses `ba100182` (parent of the squash).
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-644-2026-11-05-accept-graphical>

## Scope

The deliverable pins Ink (`PAL.C2`) `font_color` on R1's `ElapsedLabel` (`copy.elapsed`)
via `PuzzleScreen._style_elapsed_label()` so the chrome timer stays readable on Paper.
Without the pin the Label inherits the engine default face (white) and reads as missing
on Paper — same visibility class as Leave before #601.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md) S1–S4 / P1, P3 | Open path, beat-blocked mark, pause freezes elapsed and blocks marks |
| [`PTU-mark-input`](../../../../../specs/playtest/ux/mark-input.md) P1–P3 | Fill, clear, complement on the screen whose chrome was restyled |
| [`PTU-leave-resume`](../../../../../specs/playtest/ux/leave-resume.md) S2–S3 / P1–P2 | Leave → In progress → reopen restores marks and resumes elapsed; R1 timer still Ink |
| Issue AC — R1 `copy.elapsed` Ink on Paper | The reported symptom: timer readable while the puzzle is open |

Out of scope: `PTU-play-puzzle` (result screen), `PTD-solve-and-pb`, `PTD-crosses-and-fills`,
`PTD-pack-finished`, `PTU-gallery-*`, `PTU-settings`, `PTU-menu` — no rule, gallery,
settings, result, menu, or persistence code is in the diff.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| Issue AC / R1 get-set-ready | **pass** | `ElapsedLabel` drawn; text `0:00`; theme `font_color` Ink; glyphs Ink `(0.1059, 0.1569, 0.2)` on Paper |
| Issue AC / R1 ready ticking | **pass** | after 1.6 s Ready: text `0:01`, attempt elapsed 1, glyphs Ink on Paper |
| `PTD-ready-and-marks` P1 | **pass** | mark during get-set-ready left the cell clear; fill → clear → cross after ready |
| `PTU-mark-input` P1–P3 | **pass** | real tap fills, second tap clears, complement crosses |
| `PTD-ready-and-marks` P3 | **pass** | C6 pause froze elapsed at 2 for 1.5 s; marks blocked; Back resumed (2 → 3) |
| Issue AC / R1 after resume | **pass** | timer still Ink on Paper |
| `PTU-leave-resume` S2 / P1–P2 | **pass** | C1 → gallery tile `In progress`; reopen restores the cross; elapsed resumes (4); timer Ink |

Capture: `capture: RESULT pass (7 shots, 0 checks failed)`, exit 0 —
[wiki `logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-644-2026-11-05-accept-graphical).

**Control (pre-fix tree `ba100182`, one commit before the deliverable).** The same
open-path reading gives theme `font_color=(1, 1, 1, 1)` and a darkest label pixel of
Paper `(0.9569, 0.9686, 0.9725)` with lightest white `(1, 1, 1)` — no Ink glyphs, the
invisible timer the defect reports. Post-fix tree reads Ink for the same state.

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-644/2026-11-05-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-puzzle-elapsed-get-set-ready.png` | Issue AC / S2 | R1 timer `0:00` Ink on Paper in get-set-ready |
| `screenshots/02-puzzle-elapsed-ready.png` | Issue AC / S1 | R1 timer `0:01` ticking, Ink on Paper |
| `screenshots/03-puzzle-marks-ready.png` | `PTU-mark-input` P1–P3 | board after fill, clear, complement |
| `screenshots/04-settings-paused.png` | `PTD-ready-and-marks` S4 | `UI-settings` while elapsed frozen |
| `screenshots/05-puzzle-elapsed-after-resume.png` | Issue AC after resume | R1 timer still Ink |
| `screenshots/06-gallery-in-progress.png` | `PTU-leave-resume` S2 | tile reading In progress after C1 |
| `screenshots/07-puzzle-reopened-elapsed.png` | `PTU-leave-resume` P1–P2 | reopened board: cross restored, timer Ink |
| `screenshots/control-01-prefix-elapsed.png` | control | pre-fix tree: white face on Paper, no Ink glyphs |

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, harness caveats | [`notes.md`](notes.md) |
| Probe (copied to `game/` for the run, removed after) | [`probe/probe_accept_644.gd`](probe/probe_accept_644.gd) |
| Capture console (RESULT pass) | wiki page, `logs/capture.log` |
| Pre-fix control console and shot | wiki page, `logs/control-prefix-capture.log`, `screenshots/control-01-prefix-elapsed.png` |
| `DBG.2` state dump | wiki page, `logs/state-pack-004.json` |
| Screenshots (7 + control, graphical run of this build) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic`: **N/A** — verification of #644 recorded that the font-color pin does not
move Applies performance / reliability / load axes; no covering `deterministic` record
is required for this deliverable.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Notes

- **Frames.** Mobile and desktop share this scene and this styling path; the colour is
  pinned on the shared Label, so one run at the 900×1200 phone frame covers both. No
  layout, framing, or copy change is in the diff.
- **Settings Back.** At 900×1200 the settings page scrolls C3 below the fold; the resume
  leg uses `Shell.close_settings()` — the screen's own Back routing — so the judged
  pause/resume state is reached without a scroll neither protocol asks for.
- **Gallery tile C1.** Reopen uses `GalleryScreen.activate_tile()`; tile pointer path is
  `PTU-gallery-layout`'s.
