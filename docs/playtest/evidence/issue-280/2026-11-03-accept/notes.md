# Notes — issue #280 acceptance run

## What was judged

The slice's single acceptance criterion: each of pack-188, pack-189, pack-190, and pack-191 passes every item of the shared
picture bar on #294, including its index-rule subject class. Plus, because these rows change playable behavior, the
protocols they reach (see [manifest.md](manifest.md)).

## How

- Independent derivation, not the shipped script: `tools/expectations_280.py` re-implements the fill rule and reads each
  committed `-pixel.png`; `tools/nonogram.py` is its own line solver/enumerator (`SIZE = 20`). Neither imports
  `.github/scripts/puzzle_derive.py`. Output: [expect.json](expect.json).
- `puzzle_derive.py derive --size 20` from each committed square into a scratch file, compared byte-for-byte with the
  committed pixel; `judge --size 20` on the committed pixel. Both `verdict: pass` for all four.
- Graphical capture on `main@6147776` (see [reproduce.md](reproduce.md)) through the real shell, puzzle screen, and input
  events. All nine judged states were saved.

## Result

All four puzzles pass; the slice's playtest protocols pass. Nothing here is a defect.

## Notable during the run

- The mark run (#189) and the crossed board (#191) are different puzzles, so the crossed board's win is judged on a clean
  board and needs no resumed-mark accounting; #190 supplies the second result screen.
- #191 is the densest of the slice at 138 of 400 fills, still inside the 100–180 band, and its silhouette reads as a heavy
  C-ring with 40 enclosed background cells.
- The gallery tiles for the slice show their own 20×20 pictures, not the seeded `T` silhouette its neighbours still carry
  (those rows belong to slices that have not shipped their pixels yet).
- Nothing was written to `game/`: the probe was removed after the run and `--import` only refreshed the gitignored cache.
