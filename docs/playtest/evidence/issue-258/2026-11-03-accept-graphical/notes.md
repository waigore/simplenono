# Notes — issue #258 acceptance run

## What was judged

The four shipped rows of this slice at `main@7d3cd10` — `pack-102`, `pack-103`, `pack-104`, `pack-105` — through the
real shell on a graphical (Xvfb) run: gallery → puzzle → ready beat → marks → solve → result → gallery, plus the
cross-heavy board and the last-fill win. Protocols in scope and their outcomes are in
[`manifest.md`](manifest.md).

The rows' content is unchanged from PR #390's squash `84082e1` to `7d3cd10`: `git diff 84082e1 7d3cd10` lists no
`game/assets/puzzle-pictures/pack-102…105*` path, no catalog id of these eight entries, and the four `pack.json` rows
compare equal. This tree therefore plays exactly the delivered rows, even though later slices added their own.

## Blockers

None. No game or interface miss was found, so no defect is filed.

## Non-blocking marks

- **Look by measurement, not eyeball.** This session has no image input, so the K4 / `AES.P1` judgement rests on
  measurement and printed silhouettes: 0.00% warm pixels on the four pixel files and the four squares, `mean B >
  mean R` throughout, luma mean/p5/p95 134.9/65/202, 153.9/61/217, 163.0/70/208, 143.8/63/207, subject-versus-
  background contrast 104.2–138.6. The printed shapes are cool, angular, still-life forms, with no cute, warm,
  playful, gore, or horror content. A human look at `04-result-102-pictures.png` remains open for the product owner
  and blocks no bar item.
- **`pack-105` reads as one mass on the board, two in the square.** At 45×45 the stored square is two heavy blocks
  split by a narrow pale channel (7 dark masses). That channel is thinner than one 15×15 cell, so the mandated BOX
  downsample closes it and the anchored pixel is one connected 93-cell mass (rows 3–6 span columns 1–7, rows 7–11
  span columns 1–13). The class on the slice is `multi-subject and/or holed` and the catalog prompt states it, which
  is what bar item 6 asks; the square itself is multi-subject and the pixel is the unedited downsample bar item 1
  requires. Recorded for the product owner as a look note: if a gap that survives 15×15 is wanted for this row, it
  needs a regeneration with a wider channel, not a pixel edit.
- **Slice PR note is on PR #390, not this run.** Item 9 of the shared bar is satisfied there; this run only re-checks
  its claims against the committed files.
- **Host rendering.** The run used one Xvfb display with software OpenGL (llvmpipe) and a dummy audio driver. Frame
  timings on this host are not comparable with the mid-range-phone targets in `specs/definition/quality.md`; no
  quality record was produced or cited from them.
