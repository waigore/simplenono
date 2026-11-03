# Notes — issue #269 acceptance playtest

What was judged, and why each protocol is in scope for a picture slice.

## Scope decision

The deliverable is eight static picture files, their eight catalog entries, the regenerated `assets/manifest.json`, and
four rewritten `pack.json` rows (`pack-146`–`pack-149`). It changes no runtime code, but it does change playable pack
data: the fills, the clues, and which pictures the gallery tile and result screen resolve. The judged surface is
therefore the play path those rows reach — `PTU-play-puzzle`, `PTU-mark-input`, `PTD-ready-and-marks`,
`PTD-crosses-and-fills`, `PTD-solve-and-pb` — plus the gallery tile that now draws a picture pair.
`PTU-gallery-reset`, `PTD-pack-finished`, `PTU-leave-resume`, and `PTU-settings` touch no path a picture row can move,
so they are N/A here.

## What was judged

- **Pack load** — 200 entries accepted, 0 rejected. The four slice rows load with the pictures the manifest resolves.
- **`PTU-play-puzzle` P1–P2** — `pack-146` opens from the gallery through `DBG.3`, the get-set-ready beat ends, the
  last fill fires `CTR-attempt` `E1` once, the result screen draws both stored pictures, and Back returns to the
  gallery with one puzzle completed.
- **`PTD-ready-and-marks`** — marks are refused during the ready beat and allowed after it, on the shipped 15×15 board.
- **`PTU-mark-input` P1–P5 on `pack-147`** — a real pointer tap fills a clear cell, a second tap clears it, a
  right-click complement crosses a clear cell, a held drag crosses each cell of a clear run once. `DBG.2` is read after
  every gesture and agrees with the drawn mark. Unsolved marks leave the puzzle not completed on the gallery.
- **`PTD-crosses-and-fills` P1–P2** — `pack-148` has every non-solution cell crossed (130 of 225) before its 95 fills
  are placed, so a win can only land when crosses are non-fills and the committed fill set is exact. It solves once.
  `pack-146` and `pack-149` solve from their committed `solution-fills` alone.
- **`PTD-solve-and-pb` P1** — `pack-148` and `pack-149` read `ever_completed` after the solve; the gallery shows three
  completed puzzles at the end of the run (146, 148, 149).

## Falsifiable picture checks

The probe plays the shipped rows, not a fixture: a wrong clue, a wrong `solution-fills` set, or a pixel that disagrees
with its row shows up as "the board will not finish". [`expect.json`](expect.json) comes from
[`tools/expectations_269.py`](tools/expectations_269.py), which has its own PNG reader and its own line solver, so the
judgement does not lean on `puzzle_derive.py`.

| Puzzle | Filled / 225 | Unique line-logic solution | Pixel = row fills and clues | Masses | Class |
|--------|--------------|----------------------------|-----------------------------|--------|-------|
| pack-146 | 81 | yes | yes | 45 + 36 | multi-subject |
| pack-147 | 59 | yes | yes | 59 | single-subject |
| pack-148 | 95 | yes | yes | 55 + 40 | multi-subject |
| pack-149 | 80 | yes | yes | 40 + 40 | multi-subject |

## Non-blocking marks

- **Prompt prose overstates the pixel.** Each of the four catalog prompts describes a larger subject than the 15×15
  pixel renders: pack-146's "fourteen cells tall … a clear four-cell gap" is two 9-cell-tall blocks with a two-cell
  gap; pack-147's "fifteen cells tall and fourteen cells wide" C is 11×9. The class statement, tone, palette, and
  contrast all hold, so the bar's numbered items pass and nothing is held. Worth a look by the product owner; no defect
  is filed, because a catalog description is not game or interface behavior.
- **Look judgement is measured, not eyeballed.** This session has no image input. Across the four pixel files and four
  squares: 0.00 % warm pixels; pixel luma mean/p5/p95 = 163.2/81.7/215.9 (146), 166.4/50.3/215.8 (147),
  142.1/55.8/209.0 (148), 153.3/56.5/220.6 (149). The printed silhouettes are a tall block beside a block, a heavy C,
  an L beside a block, and two equal blocks. A human look at `04-result-146-pictures.png` stays open for the product
  owner.
