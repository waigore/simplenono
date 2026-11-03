# Notes — issue #268 acceptance playtest

## What was judged

Five protocols (`PTU-play-puzzle`, `PTU-mark-input`, `PTD-ready-and-marks`, `PTD-crosses-and-fills`,
`PTD-solve-and-pb`) on the shipped `game/data/pack.json` rows for pack-142, pack-143, pack-144, pack-145, through the
real shell, real pointer events, and the shipped `DBG.1`/`DBG.2`/`DBG.3` seams. Every fill placed comes from
`expect.json`, which is built from the committed `-pixel.png` files by independent code, so a wrong clue, a wrong
`solution-fills` set, or a picture whose pixel disagrees with its row shows up as "the board will not finish".

The slice's four rows are byte-identical between the delivery commits (`cbfcb9a`, repair `dafc87c`) and the build this
run used (`main@62a3d52`), so the run is a run of the delivered work.

## Per-protocol outcome

- `PTU-play-puzzle` — gallery (200 rows, 0 rejected) → pack-142 → ready beat → last fill → result with both picture
  ids resolved → Back → gallery with 1 completed. pass.
- `PTU-mark-input` — pack-143: tap fills, tap clears, complement crosses, drag crosses every cell once; `DBG.2` agrees
  after each gesture; leaving the puzzle leaves it unsolved and In progress. pass.
- `PTD-ready-and-marks` — clues drawn, marks blocked before the ready beat and allowed after. pass.
- `PTD-crosses-and-fills` — pack-144 with all 135 non-solution cells crossed still solves on its last fill, so the win
  tolerates crosses. pass.
- `PTD-solve-and-pb` — pack-142, pack-144, and pack-145 solve on the last fill, reach the result screen, and set
  ever-completed. pass.

## Prior verify fail, re-measured

The previous verify failed pack-144 and pack-145 for delivering a single open silhouette while the slice names them
multi-subject and/or holed. On this build the committed pixels are 2 masses (45 + 45) for pack-144 and 1 mass with
2 enclosed pale windows (8 cells) for pack-145, so both deliver their class.

## Blocker

None. No game or interface miss was found, so no defect.

## Non-blocking marks

1. The style/identity read is `needs human`: this session has no image input, so the look was judged only on
   measurable items (warm-pixel share, luma spread, structural classes) plus the protocol checks. The product owner can
   look at `screenshots/04-result-142-pictures.png`, `screenshots/05-gallery-142-done.png`, and
   `screenshots/09-puzzle-145-last-fill.png`.
2. The verify comment's hygiene note stands: pack-145's `review.report` says "8 enclosed pale regions" while the pixel
   has 2 regions totalling 8 cells. Wording only; the verdict and class are right. Repaired with the next entry touch.
3. pack-144's two masses sit in adjacent 5-cell blocks separated by a one-cell channel; at 15×15 it reads as two
   separated subjects, which is the class the body names. No bar item misses.
