# Notes — #706 major grid lines (graphical acceptance)

- **Issue:** #706 Open board: draw major grid lines every 5 cells in PAL.C7 Major
- **Run id:** `2026-11-06-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-06
- **Build:** `main@5bf6d88` (`game/` identical to the deliverable `007d70c`),
  Godot 4.7.2 stable, Xvfb, fresh `user://`
- **Session:** `issue-706-accept`

## What was judged

The shipped puzzle screen through the real shell, at the three supported board
sizes and both mobile orientations. Specs are the authority and were not edited:
[`PAL.C7`](../../../../../specs/aesthetics/palette.md),
[`SRF.O1`/`SRF.O2`](../../../../../specs/aesthetics/surface.md),
[`FRM.D1`/`FRM.P1`](../../../../../specs/aesthetics/form.md),
[`PAL.K6`](../../../../../specs/aesthetics/palette/rules.md).

The board assigns each cell the kind of its four sides; the cell paints those
sides. An interior boundary is owned by exactly one cell (the one before it), so a
shared edge is never drawn twice in two colours. An outer edge keeps the cell rule,
because `SRF.O2` places the majors on the open-board **grid** boundaries and
`SRF.O1` gives the frame its own edge.

## Seam read-back (graphical run)

| Board | Frame | Cell side | Majors | Minors |
|-------|-------|-----------|--------|--------|
| 10×10 | 1280×800 desktop | 40 px | 5 | all other boundaries |
| 20×20 | 1280×800 desktop | 29 px | 5, 10, 15 | all other boundaries |
| 15×15 | 1280×800 desktop | 38 px | 5, 10 | all other boundaries |
| 10×10 | 360×640 mobile | 25 px | 5 | all other boundaries |
| 20×20 | 360×640 mobile | 13 px | 5, 10, 15 | all other boundaries |
| 20×20 | 640×360 mobile | 13 px | 5, 10, 15 | all other boundaries |

Every cell's four edge kinds matched `PuzzleBoard.edge_at_boundary`; the outer
edge stayed `EDGE_RULE`; `edge_color` returned `PresentationPalette.MAJOR` /
`PresentationPalette.RULE`; and `PAL.C7` is darker than `PAL.C4`.

## Pixel read-back

The saved frames carry the exact swatches. Sampling the boundary lines inside the
grid found `#B0BBC3` on the 5-cell boundary and `#C5D0D6` on a minor boundary, with
the major line visibly darker, on every judged board.

## `PTU-play-puzzle`

- **P1** — gallery → puzzle → result → gallery completed; the last fill left for
  `UI-result`, and `UI-result.C1` Back returned to the gallery.
- **P2** — the solved `pack-000` tile reads `Done` after Back.
- **P3** — the 20×20 board stayed inside the 360×640 portrait and 640×360 landscape
  frames, one framing, no scroll or pan.

## Non-blocking

- The host is a desktop build; the mobile framing was exercised by setting
  `PuzzleBoard.PLATFORM_MOBILE`, the same seam the unit test drives. The real
  mobile build picks it from `OS.has_feature("mobile")`.
- The first attempt reused the host's stored progress (a stray fill on `pack-000`)
  and could not solve; the recorded run uses a fresh `XDG_DATA_HOME`. The board
  checks were unaffected.
