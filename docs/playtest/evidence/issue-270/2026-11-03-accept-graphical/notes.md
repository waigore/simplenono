# Notes — issue #270 acceptance playtest

## What was judged

Five protocols (`PTU-play-puzzle`, `PTU-mark-input`, `PTD-ready-and-marks`, `PTD-crosses-and-fills`,
`PTD-solve-and-pb`) on the shipped `game/data/pack.json` rows for pack-150, pack-151, pack-152, pack-153, through the
real shell, real pointer events, and the shipped `DBG.1`/`DBG.2`/`DBG.3` seams. Every fill placed comes from
`expect.json`, which is built from the committed `-pixel.png` files by independent code, so a wrong clue, a wrong
`solution-fills` set, or a picture whose pixel disagrees with its row shows up as "the board will not finish".

The slice's four rows are byte-identical between the delivery commit (`a967bfc`, PR #422's squash) and the build this
run used (`main@d688934`), so the run is a run of the delivered work.

## Per-protocol outcome

- `PTU-play-puzzle` — gallery (200 rows, 0 rejected) → pack-150 → ready beat → last fill → result with both picture
  ids resolved → Back → gallery with 1 completed. pass.
- `PTU-mark-input` — pack-151: tap fills, tap clears, complement crosses, drag crosses every cell once; `DBG.2` agrees
  after each gesture; leaving the puzzle leaves it unsolved and In progress. pass.
- `PTD-ready-and-marks` — clues drawn, marks blocked before the ready beat and allowed after. pass.
- `PTD-crosses-and-fills` — pack-152 with all 143 non-solution cells crossed still solves on its last fill, so the win
  tolerates crosses. pass.
- `PTD-solve-and-pb` — pack-150, pack-152, and pack-153 solve on the last fill, reach the result screen, and set
  ever-completed. pass.

## Shared picture bar (#294) — re-measured, not trusted

Every number in the implementation and verification comments was re-measured on this build with code that does not
import `.github/scripts/puzzle_derive.py`: fills 70 / 81 / 82 / 84 (all inside 56–101), one solution each, line logic
reaches each solution, clues and `solution-fills` match the pack rows, derived pixels byte-identical to the committed
ones. Classes match the slice assignment: pack-150 and pack-153 single-subject, pack-151 and pack-152 multi-subject.

One wording note, not a miss: verification called pack-150 "one enclosed hole". The pixel has one contiguous enclosed
pale region of 51 cells inside a bowl-shaped mass — one region, many cells. Verdict and class are right.

## Blocker

None in the game or interface. Acceptance stops short of **Accept** for one reason outside the game: the
`time-to-playable` deterministic record for this deliverable's `game/` tree is missing (see the acceptance comment).
That is the `pending-acceptance` → `pending-verification` route, not a defect.

## Non-blocking marks

1. **Look is `needs human`.** This session cannot read images, so the look was judged on measurable items only
   (warm-pixel share 0.00 % on all eight files, luma spread, geometric classes) plus the protocol checks. The product
   owner can look at `screenshots/04-result-150-pictures.png`, `screenshots/05-gallery-150-done.png`, and
   `screenshots/09-puzzle-153-last-fill.png`.
2. **pack-150's silhouette is the weakest of the four.** It is a bowl-shaped mass enclosing a 51-cell cavity. It meets
   every bar item (one mass, in band, unique, calm), but it reads more as a container than an object at 15×15. Not a
   bar miss; worth the pack-wide look #294 is already doing.
3. **Duplicate silhouettes remain an epic-level point.** Confirmed by set equality on this build: pack-151's fill set is
   identical to `pack-046`, `pack-146`, and `pack-154`; the other three slice puzzles are unique. No kind row forbids
   repeats (`V1` asks only for a pair per puzzle), so this is not a slice finding; it stays #294's.
4. `.github/scripts/picture_slice.py` still hard-codes `--size 10` in its prompt text. This slice used the documented
   manual `puzzle_derive.py` command, so it is unaffected.
