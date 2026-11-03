# Notes — issue #267 acceptance playtest

## What was judged

Five protocols (`PTU-play-puzzle`, `PTU-mark-input`, `PTD-ready-and-marks`, `PTD-crosses-and-fills`,
`PTD-solve-and-pb`) on the shipped `game/data/pack.json` rows for pack-138, pack-139, pack-140, pack-141, through
the real shell, real pointer events, and the shipped `DBG.1`/`DBG.2`/`DBG.3` seams. Every fill placed comes from
`expect.json`, which is built from the committed `-pixel.png` files by independent code, so a wrong clue, a wrong
`solution-fills` set, or a picture whose pixel disagrees with its row shows up as "the board will not finish".

The slice's four rows are byte-identical between the delivery commit `c2b1a04` and the build this run used
(`main@8595d3f`), so the run is a run of the delivered work.

## Per-protocol outcome

- `PTU-play-puzzle` — gallery (200 rows, 0 rejected) → pack-138 → ready beat → last fill → result with both
  pictures resolved → Back → gallery with 1 completed. pass.
- `PTU-mark-input` — pack-139: tap fills, tap clears, complement crosses, three-cell drag crosses each cell once;
  `DBG.2` agrees after each gesture; leaving the puzzle leaves it unsolved and In progress. pass.
- `PTD-ready-and-marks` — clues drawn, marks blocked before the ready beat and allowed after. pass.
- `PTD-crosses-and-fills` — pack-140 with all 169 non-solution cells crossed still solves on its last fill, so the
  win tolerates crosses. pass.
- `PTD-solve-and-pb` — pack-138 and pack-141 solve on the last fill, reach the result screen, and set
  ever-completed. pass.

## Blocker

None. No game or interface miss was found, so no defect.

## Non-blocking marks

1. The style/identity read is `needs human`: this session has no image input, so the look was judged only on
   measurable items (warm-pixel share, luma, structural classes) plus the protocol checks. The product owner can
   look at `screenshots/04-result-138-pictures.png` and `screenshots/05-gallery-138-done.png`.
2. pack-140 is at the band floor (56 fills). In band, nothing to do.
3. The catalog prompt wording for pack-140 names larger cell counts than the delivered ring; `generation.prompt`
   records the prompt as run and the named shape is the delivered shape. Same note as verification.
