# Notes — issue #279 acceptance run

## What was judged

The slice's single acceptance criterion: each of pack-184, pack-185, pack-186, and pack-187 passes every item of the shared
picture bar on #294, including its index-rule subject class. Plus, because these rows change playable behavior, the
protocols they reach (see [manifest.md](manifest.md)).

## How

- Independent derivation, not the shipped script: `tools/expectations_279.py` re-implements the fill rule and reads each
  committed `-pixel.png`; `tools/nonogram.py` is its own line solver/enumerator (`SIZE = 20`). Neither imports
  `.github/scripts/puzzle_derive.py`. Output: [expect.json](expect.json).
- `puzzle_derive.py derive --size 20` from each committed square into a scratch file, compared byte-for-byte with the
  committed pixel; `judge --size 20` on the committed pixel. Both `verdict: pass` for all four.
- Graphical capture on `main@05ef321` (see [reproduce.md](reproduce.md)) through the real shell, puzzle screen, and input
  events. All nine judged states were saved.

## Result

All four puzzles pass; the slice's playtest protocols pass. Nothing here is a defect.

## Notable during the run

- The mark run (#185) and the crossed board (#186) are different puzzles, so the crossed board's win is judged on a clean
  board and needs no resumed-mark accounting; #187 supplies the second result screen.
- #186 is the densest of the slice at 175 of 400 fills, still inside the 100–180 band, and its silhouettes read as two
  upright blocks separated by a clean channel.
- Nothing was written to `game/`: the probe was removed after the run and `--import` only refreshed the gitignored cache.
