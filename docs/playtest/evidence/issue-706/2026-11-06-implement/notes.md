# Notes — #706 major grid lines

- **Issue:** #706 Open board: draw major grid lines every 5 cells in PAL.C7 Major
- **Run id:** `2026-11-06-implement`
- **Runner:** `issue-workflow-implement-agent` (parallel id 1), unattended, 2026-11-06
- **Branch:** `orc/issue-workflow-implement-agent-1/20261106T122941363256Z` (from `23e1856`)
- **Build:** Godot 4.7.2 headless, 4 cores

## What was judged

The draw seam only. Specs are the authority and were not edited: [`PAL.C7`](../../../../../specs/aesthetics/palette.md),
[`SRF.O1`/`SRF.O2`](../../../../../specs/aesthetics/surface.md), [`FRM.D1`/`FRM.P1`](../../../../../specs/aesthetics/form.md),
[`PAL.K6`](../../../../../specs/aesthetics/palette/rules.md).

The board assigns each cell the kind of its four sides; the cell paints those sides. An interior
boundary is owned by exactly one cell (the one before it), so a shared edge is never drawn twice
in two colours. An outer edge keeps the cell rule, because `SRF.O2` places the majors on the
open-board **grid** boundaries and `SRF.O1` gives the frame its own edge.

## Facet read-back (headless)

| Board | Viewport / platform | Cell side | Majors (colour `#b0bbc3`) | Minors (colour `#c5d0d6`) |
|-------|---------------------|-----------|---------------------------|---------------------------|
| 10×10 | 1280×800 desktop | 40 px | 5 | all other boundaries |
| 20×20 | 1280×800 desktop | 29 px | 5, 10, 15 | all other boundaries |
| 10×10 | 360×640 mobile | 25 px | 5 | all other boundaries |
| 20×20 | 360×640 mobile | 13 px | 5, 10, 15 | all other boundaries |

Cell sides equal the `ACHIEVED_CELL` values pinned in `game/test/test_puzzle_board.gd`, so the
board geometry, clue bars, and tap areas are unchanged.

## Non-blocking

- **Screenshots are waiting on a graphical run.** This repo has no screenshot or rendering lane
  (the harness is headless; `docs/playtest/evidence.md` says a headless run marks screenshots
  waiting). The seam read-back above and `test_puzzle_major_lines.gd` are the evidence for this
  run.
- `paint` I9 "missing flows (open only)" in the harness is unrelated (#699).
