# Notes — issue #262 acceptance run

## What was judged

The four shipped rows of this slice at `main@1161953` — `pack-118`, `pack-119`, `pack-120`, `pack-121` — through the
real shell on a graphical (Xvfb) run: gallery → puzzle → ready beat → marks → solve → result → gallery, plus the
cross-heavy board and the last-fill win. Protocols in scope and their outcomes are in [`manifest.md`](manifest.md).

The rows' content is unchanged from PR #397's squash `fdbfa63` to `1161953`: `git diff fdbfa63 1161953` lists no
`game/assets/puzzle-pictures/pack-118…121*` path and no catalog id of these eight entries, and the four `pack.json`
rows compare equal (`rows('fdbfa63')[id] == rows('1161953')[id]`, True on all four). This tree therefore plays
exactly the delivered rows, even though later slices added their own.

## Blockers

None. No game or interface miss was found, so no defect is filed.

## Non-blocking marks

- **Look by measurement, not eyeball.** This session has no image input, so the K4 / `AES.P1` judgement rests on
  measurement and printed silhouettes: 0.00% warm pixels on the four pixel files and the four squares, `mean B >
  mean R` throughout, pixel luma mean/p5/p95 157.4/49.0/205.2, 159.3/76.3/209.4, 157.0/82.4/203.2, 160.1/54.9/214.2.
  The printed shapes are cool, angular, still-life forms with no cute, warm, playful, gore, or horror content:

  ```
  pack-118 (62, two masses)        pack-119 (79, two masses)
  ...............                  ...............
  ...............                  ...............
  ...............                  ..###########..
  ..####.........                  ..###########..
  ..####.........                  ..###########..
  ..####..#####..                  ..###########..
  ..####.#######.                  .......#..#.#..
  ..####.#######.                  ...............
  ..####.#######.                  .....######....
  ..####.........                  .....######....
  ..####.........                  .....######....
  ..####.........                  .....######....
  ...............                  .....######....
  ...............                  .......#..#....
  ...............                  ...............

  pack-120 (84, single mass)       pack-121 (73, two masses)
  ...............                  ...............
  ....######.....                  ...............
  ....######.....                  ...............
  ....######.....                  ...............
  ....######.....                  ..#####........
  ....######.....                  .######.######.
  ....######.....                  .######.######.
  ....######.....                  .######.######.
  ....#######....                  .######.######.
  ....#######....                  .######.######.
  ....#######....                  ..#####........
  ....#######....                  ...###.........
  ....#######....                  ...............
  ....#######....                  ...............
  ...............                  ...............
  ```

  A human look at `04-result-118-pictures.png` remains open for the product owner and blocks no bar item.
- **`pack-120` is the slice's single-subject row.** Its pixel is one connected 84-cell mass and its catalog prompt
  states `single-subject`, which is what item 6 asks; the pack-wide ~30/70 mix (`V2`, `K5`) stays on #294.
- **Slice PR note is on PR #397, not this run.** Item 9 of the shared bar is satisfied there; this run re-checks its
  claims against the committed files.
- **Host rendering.** The run used one Xvfb display with software OpenGL (llvmpipe) and a dummy audio driver. Frame
  timings on this host are not comparable with the mid-range-phone targets in `specs/definition/quality.md`; no
  quality record was produced or cited from them (the cited deterministic record is the verifier's headless one).
