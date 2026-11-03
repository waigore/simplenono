# Notes — issue #278 acceptance run

## What was judged

The slice's single acceptance criterion: each of pack-180, pack-181, pack-182, and pack-183 passes every item of the shared
picture bar on #294, including its index-rule subject class. Plus, because these rows change playable behavior, the
protocols they reach (see [manifest.md](manifest.md)).

## How

- Independent derivation, not the shipped script: `tools/expectations_278.py` re-implements the fill rule and reads each
  committed `-pixel.png`; `tools/nonogram.py` is its own line solver/enumerator (`SIZE = 20`). Neither imports
  `.github/scripts/puzzle_derive.py`. Output: [expect.json](expect.json).
- `puzzle_derive.py derive --size 20` from each committed square into a scratch file, compared byte-for-byte with the
  committed pixel; `judge --size 20` on the committed pixel. Both `verdict: pass` for all four.
- Graphical capture on `main@893e60f` (see [reproduce.md](reproduce.md)) through the real shell, puzzle screen, and input
  events. All nine judged states were saved.

## Result

All four puzzles pass; the slice's playtest protocols pass. Nothing here is a defect.

## Notable during the run

- This is the first 20×20 slice, so the fill band is 100–180 cells (25–45 % of 400) and the mark, crossed, and last-fill
  boards are 20×20: 400 cells, up from 225 on the 15×15 slices. The capture drove them without change.
- #183 is the sparsest of the slice at 105 of 400 fills — 5 cells above the band floor — and it is a single connected
  mass, so it is legal under the index rule; its low count is why it is the last board filled.
- #181 is the mark run, not a solved board, so its 21 enclosed background cells are shown on screen (`06`) but not
  crossed by the run. Its shape is judged offline by `expect.json` (fills, clues, one solution, pixel agreement), and
  #182 covers the solved multi-subject case in the capture (`08`, `09`).
- Nothing was written to `game/`: the probe was removed after the run and `--import` only refreshed the gitignored cache.
