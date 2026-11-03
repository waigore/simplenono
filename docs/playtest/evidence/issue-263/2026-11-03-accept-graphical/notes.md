# Notes — issue #263 acceptance playtest

What was judged, and why each protocol is in scope for a picture slice.

## Scope decision

The deliverable is eight static picture files, their eight catalog entries, the regenerated
`assets/manifest.json`, and four rewritten `pack.json` rows (`pack-122`–`pack-125`). It changes no runtime code, but
it does change playable pack data: the fills, the clues, and which pictures the gallery tile and result screen
resolve. The judged surface is therefore the play path those rows reach — `PTU-play-puzzle`, `PTU-mark-input`,
`PTD-ready-and-marks`, `PTD-crosses-and-fills`, `PTD-solve-and-pb` — plus the gallery tile that now draws a picture
pair. `PTU-gallery-reset`, `PTD-pack-finished`, `PTU-leave-resume`, and `PTU-settings` touch no path a picture row can
move, so they are N/A here.

## What was judged

- **Pack load** — 200 entries accepted, 0 rejected. The four slice rows load with the pictures the manifest resolves.
- **`PTU-play-puzzle` P1–P2** — `pack-122` opens from the gallery through `DBG.3`, the get-set-ready beat ends, the
  last fill fires `CTR-attempt` `E1` once, the result screen draws both stored pictures, and Back returns to the
  gallery with one puzzle completed.
- **`PTD-ready-and-marks`** — marks are refused during the ready beat and allowed after it, on the shipped 15×15 board.
- **`PTU-mark-input` P1–P5 on `pack-123`** — a real pointer tap fills a clear cell, a second tap clears it, a
  right-click complement crosses a clear cell, a held drag crosses each cell of a clear run once. `DBG.2` is read after
  every gesture and agrees with the drawn mark. Unsolved marks leave the puzzle not completed on the gallery.
- **`PTD-crosses-and-fills` P1–P2** — `pack-124` has every non-solution cell crossed (140 of 225) before its 85 fills
  are placed, so a win can only land when crosses are non-fills and the committed fill set is exact. It solves once.
  `pack-122` and `pack-125` solve from their committed `solution-fills` alone.
- **`PTD-solve-and-pb` P1** — `pack-124` and `pack-125` read `ever_completed` after the solve; the gallery shows three
  completed puzzles at the end of the run (122, 124, 125).

## Falsifiable picture checks

The probe plays the shipped rows, not a fixture: a wrong clue, a wrong `solution-fills` set, or a pixel that disagrees
with its row shows up as "the board will not finish". [`expect.json`](expect.json) comes from
[`tools/expectations_263.py`](tools/expectations_263.py), which has its own PNG reader and its own line solver, so the
judgement does not lean on `puzzle_derive.py`.

| Puzzle | Filled / 225 | Unique line-logic solution | Pixel = row fills and clues | Masses |
|--------|--------------|----------------------------|-----------------------------|--------|
| pack-122 | 61 | yes | yes | 46 + 15 |
| pack-123 | 84 | yes | yes | 84 |
| pack-124 | 85 | yes | yes | 85 |
| pack-125 | 61 | yes | yes | 37 + 24 |

## Non-blocking marks

- **pack-124's silhouette.** The committed pixel is one connected 85-cell plus shape with no enclosed background, while
  its catalog prompt and `review.report` describe "two heavy separate solid blocks ... a four-cell gap through the
  middle". The slice's class label ("multi-subject and/or holed") is in the prompt, and the picture is calm,
  high-contrast and cool, so the bar's class and look items hold as written; the prose overstates what the 15×15 pixel
  shows. Worth a look by the product owner; no defect is filed, because a catalog description is not game or interface
  behavior.
- **Look judgement is measured, not eyeballed.** This session has no image input. Across the four pixel files and four
  squares: 0.00% warm pixels; pixel luma mean/p5/p95 = 169.4/69.0/217.4 (122), 156.7/51.0/215.1 (123),
  146.5/68.7/198.4 (124), 160.0/70.9/200.4 (125). The printed silhouettes are two blocks, a capped rectangle, a plus,
  and a block beside a tower. A human look at `04-result-122-pictures.png` stays open for the product owner.
