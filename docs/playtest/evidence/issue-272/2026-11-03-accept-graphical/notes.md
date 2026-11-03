# Notes — issue #272 acceptance playtest

## What was judged

Five protocols (`PTU-play-puzzle`, `PTU-mark-input`, `PTD-ready-and-marks`, `PTD-crosses-and-fills`,
`PTD-solve-and-pb`) on the shipped `game/data/pack.json` rows for pack-158, pack-159, pack-160, pack-161, through the
real shell, real pointer events, and the shipped `DBG.1`/`DBG.2`/`DBG.3` seams. Every fill placed comes from
`expect.json`, which is built from the committed `-pixel.png` files by independent code, so a wrong clue, a wrong
`solution-fills` set, or a picture whose pixel disagrees with its row shows up as "the board will not finish".

The slice's four rows, eight picture files, eight sidecars, and eight catalog entries are byte-identical between the
delivery commit (`b2046dd`, PR #419's squash) and the build this run used (`main@5b260e8`), so the run is a run of the
delivered work.

## Per-protocol outcome

- `PTU-play-puzzle` — gallery (200 rows, 0 rejected) → pack-158 → ready beat → last fill → result with both picture
  ids resolved → Back → gallery with 1 completed. pass.
- `PTU-mark-input` — pack-159: tap fills, tap clears, complement crosses, drag crosses every cell once; `DBG.2` agrees
  after each gesture; leaving the puzzle leaves it unsolved and In progress. pass.
- `PTD-ready-and-marks` — clues drawn, marks blocked before the ready beat and allowed after. pass.
- `PTD-crosses-and-fills` — pack-160 with all 168 non-solution cells crossed still solves on its last fill, so the win
  tolerates crosses. pass.
- `PTD-solve-and-pb` — pack-158, pack-160, and pack-161 solve on the last fill, reach the result screen, and set
  ever-completed. pass.

## Shared picture bar (#294) — re-measured, not trusted

Every number in the implementation and verification comments was re-measured on this build with code that does not
import `.github/scripts/puzzle_derive.py`: fills 82 / 83 / 57 / 75 (all inside the 56–101 band), one solution each,
line logic reaches each solution, clues and `solution-fills` match the pack rows, and each derived pixel is
byte-identical to its committed pixel. Classes match the slice assignment: pack-160 (index 0) is single-subject — one
solid mass with no enclosed region; pack-158, pack-159, pack-161 are multi-subject and/or holed (pack-158 and pack-161
one mass with 8 and 6 enclosed cells, pack-159 two masses of 54 and 29).

## Blocker

None in the game or interface. All acceptance criteria pass; see the acceptance comment for the outcome.

## Non-blocking marks

1. **Look is `needs human`.** This session cannot read images, so the look was judged on measurable items only
   (warm-pixel share 0.00 % on all eight files, luma spread, geometric classes) plus the protocol checks. The product
   owner can look at `screenshots/04-result-158-pictures.png`, `screenshots/05-gallery-158-done.png`, and
   `screenshots/09-puzzle-161-last-fill.png`.
2. **pack-160 repeats an existing picture.** Its `Y < 128` fill set equals `pack-063` and `pack-137` (verification
   recorded the same group). No kind row forbids repeats (`V1` asks only for a pair per puzzle); pack-wide mix and
   distinctness stay #294's. Recorded here for the epic.
3. `.github/scripts/picture_slice.py` still hard-codes `--size 10` in its prompt text. This slice used the documented
   manual `puzzle_derive.py --size 15` command, so it is unaffected.
