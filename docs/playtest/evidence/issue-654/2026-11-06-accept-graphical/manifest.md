# Playtest run — issue #654 (graphical acceptance, hint-free status + gallery star)

- **Issue:** #654 Hint-free solve status + gallery star (`type:task`, `status:pending-acceptance`,
  `priority:normal`)
- **Run id:** `2026-11-06-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-06
- **Build / session id:** the deliverable tree `main@377af2b` (PR #678), session
  `issue-654-accept`, Godot `4.7.2.stable.official.ed1daf0bf`, Linux x86_64, Xvfb
  900×1200 (the mobile mockup frame), fresh `user://`. The issue's code is PR #665
  (`4679bb9`) and PR #667 (`5217e5e`); `377af2b` is `main` at the run and adds only the
  deterministic evidence record on top of `26008cc`.
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-654-2026-11-06-accept-graphical>

## Scope

The deliverable persists `GS.hint-free` per puzzle (`SCH-progress` F7), earns it on a
clean solve (`PS1.8`), voids it when any hint is enabled during an active attempt
(`PS1.9`, even if unused), re-earns it on a later clean solve, clears it on gallery
reset, and paints the `PER.R7` / `UIS.I1` clinical star at the gallery thumb's
upper-left.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTD-solve-and-pb`](../../../../../specs/playtest/design/solve-and-pb.md) S4 / P4 / F3 | Clean solve earns; enable voids; reset clears hint-free |
| [`PTU-gallery-reset`](../../../../../specs/playtest/ux/gallery-reset.md) S1–S3 / P1–P2 | Cancel keeps it; Confirm clears hint-free with the rest; tile returns to Default |
| Issue AC — clean solve shows the star upper-left | The visible deliverable on `UI-gallery` R2 |
| Issue AC — an unused enable still voids | `PS1.9` bars hint-free even with the assist unused |
| Issue AC — a later clean solve re-earns | `PS1.9` re-earn after a void |

Out of scope: `PTD-ready-and-marks`, `PTD-crosses-and-fills`, `PTD-clue-dim`,
`PTD-pack-finished`, `PTU-menu`, `PTU-play-puzzle`, `PTU-leave-resume`,
`PTU-gallery-layout`, `PTU-settings`, `PTU-mark-input` — no rule, marks, clue, menu,
result, settings, or layout code is in the deliverable's diff. The hint-assist toggles
themselves are sibling #651.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-solve-and-pb` S4 / P4 (earn) | **pass** | a real clean solve (39 pointer fills) set `ever-completed` and `hint-free`; the record and a fresh `Pack` agree |
| Issue AC / star upper-left | **pass** | `PER.R7` star drawn at the thumb's upper-left: 18 Ink px inside the star block on Paper; held metrics 14 px at 6 px on the 900×1200 frame (`UIS.I1`) |
| `PTD-solve-and-pb` S4 / P4 (void) | **pass** | enabling `C5` mid-attempt dropped `GS.hint-free-eligible` and cleared the durable flag at once; gallery entry and tile drop the star (0 Ink px) |
| Issue AC / unused enable | **pass** | solved with the assist enabled but never used: `hint-free` stays false, no star |
| `PTD-solve-and-pb` S4 / P4 (re-earn) | **pass** | a later clean solve is eligible again and re-earns; star back on the tile |
| `PTU-gallery-reset` P1 | **pass** | `EX.confirm` Cancel kept ever-completed, hint-free, and the PB |
| `PTU-gallery-reset` P2 | **pass** | Confirm cleared ever-completed, PB, and hint-free; tile reads `Not started` (Default), no star (0 Ink px) |

Capture: `capture: RESULT pass (7 shots, 0 checks failed)`, exit 0 —
[`logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-654-2026-11-06-accept-graphical).

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-654/2026-11-06-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-clean-solve-sets-hint-free.png` | `PTD-solve-and-pb` P4 | result screen after the clean solve; record carries hint-free |
| `screenshots/02-gallery-star-upper-left.png` | Issue AC / `PER.R7`, `UIS.I1`, `US1.8` | gallery tile with the Ink star at the thumb's upper-left |
| `screenshots/03-enabled-hint-voids.png` | `PTD-solve-and-pb` P4 (void) | gallery after the mid-attempt enable: no star |
| `screenshots/04-unused-enable-no-star.png` | Issue AC / unused enable | gallery after solving with the assist enabled but unused: no star |
| `screenshots/05-clean-solve-re-earns.png` | `PTD-solve-and-pb` P4 (re-earn) | gallery after a later clean solve: star back |
| `screenshots/06-reset-confirm.png` | `PTU-gallery-reset` S1 | `EX.confirm` for the hint-free puzzle |
| `screenshots/07-reset-clears-hint-free.png` | `PTU-gallery-reset` P2 | tile back to Default with no star |

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, harness caveats | [`notes.md`](notes.md) |
| Probe (copied to `game/` for the run, removed after) | [`probe/probe_accept_654.gd`](probe/probe_accept_654.gd) |
| Capture console (RESULT pass) | wiki page, `logs/capture.log` |
| `DBG.2` state dump | wiki page, `logs/state-pack-004.json` |
| Screenshots (7, graphical run of this build) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic`: **pass** — [`docs/quality/evidence/issue-654/2026-11-06-verify/manifest.md`](../../../../quality/evidence/issue-654/2026-11-06-verify/manifest.md)
(PR #678), `save-survives` and `failed-write` both pass. The record was taken at
`26008cc` and `main` has since gained #677 (`903b921`, the settings-chrome re-land), so
`git diff 26008cc 903b921 -- game/` is not empty and the tree match is not exact. That
diff touches only settings chrome and its tests; the gallery and progress files this
deliverable owns are unchanged (`git diff 26008cc 377af2b -- game/presentation/gallery*.gd
game/presentation/gallery.tscn game/records/ game/play/` is empty). This run did not
re-run the evaluators — acceptance cites, it does not re-run `deterministic`. The
shipped tree's full GUT suite passes locally on a fresh `user://` — 432/432, including
every test the record cites (`test_hint_free.gd`, `test_pack_progress.gd`).

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Notes

- **Frames.** The star metrics follow the frame (`UIS.I1`) like the body padding
  (#557): 14 px at a 6 px inset above 720 px wide, 12 px at 4 px below. This run judged
  the 900×1200 mobile mockup frame only; the wide branch is held by the `US1.8` unit
  test and the approved `MC.gallery-desktop` mockup. No layout or copy change is in the
  deliverable.
- **Tile visibility.** The gallery scrolls: at 900×1200 the puzzle's tile (pack-004,
  index 4) sits below the fold. The probe scrolls it into view with
  `ScrollContainer.ensure_control_visible` before sampling pixels; that is a scroll, not
  a layout change, and the held star metrics come from the gallery either way.
- **Intro frame.** The first gallery return after a solve settles over a frame or two:
  the shell's return path re-reads O1 and the tiles are rebuilt. The probe settles 3
  frames before reading entries and sampling pixels. No product miss observed after the
  settle; the earlier reads were a probe race, not a defect.
- **Result C1.** `UI-result.C1` is inert while the morph runs (`US1.3`), so the probe
  ends the morph (`ResultScreen.finish_morph`), checks `can_go_back()`, and presses
  through the shell's `IN.back` route.
