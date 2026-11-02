# Notes — issue #248 acceptance

Run folder: [`manifest.md`](manifest.md). Build `main@1ea9dd2`, graphical, 2026-11-03.

## What was judged

**Picture bar (#294).** Nothing here restates the bar; the slice's evidence is:

| Puzzle | Class on the slice | Measured (pixel, 4-connectivity) | Filled / 225 | Unique | Line logic | Re-derive vs committed |
|--------|--------------------|----------------------------------|--------------|--------|------------|------------------------|
| pack-062 | multi-subject and/or holed | 2 masses (46 + 25), 0 holes | 71 (band 56–101) | 1 solution | solves | byte-identical (`cmp`) |
| pack-063 | single-subject | 1 mass (57), 0 holes | 57 | 1 solution | solves | byte-identical |
| pack-064 | multi-subject and/or holed | 1 mass (59), 18 holes | 59 | 1 solution | solves | byte-identical |
| pack-065 | multi-subject and/or holed | 2 masses (63 + 30), 0 holes | 93 | 1 solution | solves | byte-identical |

The measured classes are the issue's index-rule classes (063 is the only single-subject).

**Fill criterion, clues, ids.** `tools/expectations_248.py` reads each pixel
independently (alpha over white, `Y = 0.2126R + 0.7152G + 0.0722B`, filled when
`Y < 128`) and reports for all four puzzles `fills == pack solution-fills`,
`row-clues == pack row-clues`, `col-clues == pack col-clues`. `generate_pack.py
--check` says `game/data/pack.json` is current; the pack row encoding is `[row,
column]` pairs, and the comparison above uses that order.

**Look (`AES.P1`, K4).** Opened each 15×15 pixel and each 1024² square. Measured on
the pixels: 0.00% warm pixels (red-over-blue bias ≥ 25) on all four; mean luma gap
between mass and ground 89.6 / 132.3 / 99.9 / 95.9. Shapes read as: a heavy bar plus a
block; a bold plus; a perforated slab seen from above; an L-shaped mass plus a block.
No cute, warm, playful, gore, or horror trait. `review.verdict: Pass` on all eight
catalog entries; each prompt states its slice class.

**Catalog and manifest.** `asset_catalog.py` → 0 errors; `asset_manifest.py --check`
→ 0 errors. The eight entries are `state: approved` at the rows' existing
`picture-id` / `pixel-picture-id`, handles `puzzle-pictures/<pack-id>-generated` and
`-pixel`.

## In-game checks (graphical)

`probe_capture_248.gd` drives the real shell, puzzle screen, shipped `DBG.1`–`DBG.3`
seams, and real pointer events on the shipped rows. Every fill it places is a
committed `solution-fills` cell, so a wrong clue, a wrong fill set, or a pixel that
disagrees with its row shows up as an unfinishable board. All 34 checks passed:
gallery → puzzle → solve → result → Back on pack-062 (with both result pictures
resolving); fill / clear / complement / drag on pack-063 with `DBG.2` agreement; full
cross-then-solve on pack-064; solve and ever-completed on pack-065. Console log:
`logs/capture-console.log`.

## Blockers and non-blocking marks

- None blocking.
- The result screen draws the generated square only; the 15×15 pixel is shown by the
  result morph on #95 (out of scope for this slice). Not a defect.
- `probe_capture_248.gd` was added to the deliverable worktree only for the run and
  is kept in `probe/` here; it is not part of the shipped tree.
- The leave/resume, settings, gallery-reset, and pack-finished protocols do not touch
  picture data and were not run.
