# Notes — issue #610 acceptance run

## What was judged

The 17 pairs the `K5` closing review regenerated (PR #621), as shipped on `main@006de2c`:
`pack-002` (10×10), fourteen 15×15 pairs (`049`, `058`, `081`, `083`, `092`, `098`, `111`,
`137`, `140`, `144`, `146`, `151`, `160`, `167`), and two 20×20 pairs (`184`, `188`).
Every other pair keeps its files and catalog row untouched and was not re-judged here.

The probe drives the real shell, puzzle screen, and input events through the shipped
`DBG.1`/`DBG.2`/`DBG.3` seams. Every fill it places is one of the committed row's
`solution-fills`, so a wrong clue, a wrong `solution-fills` set, or a picture whose pixel
disagrees with the row shows up as "the board will not finish".

## Independent derivation

[`tools/expectations_610.py`](tools/expectations_610.py) re-derives each pair's fill set
from the committed pixel file with its own PNG reader and the kind spec's exact
`Y = 0.2126R + 0.7152G + 0.0722B` rule, then derives the clues and solves them with
[`tools/nonogram610.py`](tools/nonogram610.py) — not `.github/scripts/puzzle_derive.py`.
All 17 pairs: one solution, line logic alone reaches it, the fill set equals the committed
`solution-fills` and clues, and the fill sits inside the `K2` band.

| Pair | Size | Fills | Solutions | Square mean saturation | Catalog version |
|---|---|---|---|---|---|
| `pack-002` | 10×10 | 33 | 1 | 0.465 | 3 |
| `pack-049` | 15×15 | 93 | 1 | 0.297 | 2 |
| `pack-058` | 15×15 | 78 | 1 | 0.375 | 2 |
| `pack-081` | 15×15 | 67 | 1 | 0.301 | 2 |
| `pack-083` | 15×15 | 101 | 1 | 0.421 | 2 |
| `pack-092` | 15×15 | 89 | 1 | 0.327 | 2 |
| `pack-098` | 15×15 | 87 | 1 | 0.327 | 2 |
| `pack-111` | 15×15 | 64 | 1 | 0.349 | 2 |
| `pack-137` | 15×15 | 89 | 1 | 0.186 | 3 |
| `pack-140` | 15×15 | 75 | 1 | 0.396 | 2 |
| `pack-144` | 15×15 | 88 | 1 | 0.22 | 2 |
| `pack-146` | 15×15 | 88 | 1 | 0.259 | 2 |
| `pack-151` | 15×15 | 90 | 1 | 0.355 | 2 |
| `pack-160` | 15×15 | 89 | 1 | 0.39 | 2 |
| `pack-167` | 15×15 | 82 | 1 | 0.358 | 2 |
| `pack-184` | 20×20 | 113 | 1 | 0.295 | 3 |
| `pack-188` | 20×20 | 139 | 1 | 0.312 | 3 |

## Judgement notes

- **`pack-002`** is the solve board: gallery → open → ready beat → one fill from solve →
  result → Back. The result screen resolves both the generated square and the pixel.
- **`pack-049`** is the mark board and is left in progress, so its gallery tile correctly
  shows the generic placeholder (`GS.gallery-thumbnail`: stored picture only after
  ever-completed). Its empty-clue rows/columns (0, 14) stay clear through the ready beat.
- **`pack-184`** is the crossed board: every non-solution cell is crossed before the
  solving fills, and the win tolerates them.
- **`pack-188`** is the last-fill board; the shot is the deciding frame after
  `finish_morph()`, not a blur mid-fade.
- **`pack-137`** is the market-awning near-twin's replacement; its result frame is the
  15×15 band's judged result.
- The gallery check reads the shell's own picture provider (the callable the gallery hands
  to each tile) for all 17, then reads each tile's `GalleryThumb.shows_picture()`: the 16
  completed tiles draw their stored picture, `pack-049` draws the placeholder.

## Non-blocking marks

- The visual `K4` look (colourful readable scene at `N×N`) was not judged by this session:
  it has no image input. The look sentences and measured facts are in the catalog entries,
  and the closing-audit contact sheets are on the wiki for human confirmation. This is not
  a protocol fail.
- The build under test (`006de2c`) carries #625's clue-label layout on top of the
  deliverable (`249aa66`). No protocol here reaches that code; the clue bars render
  normally in the shots.

## Blockers

None.
