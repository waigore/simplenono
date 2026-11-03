# Notes — issue #277 acceptance run

## What was judged

The slice's single acceptance criterion: each of pack-178 and pack-179 passes every item of the shared picture bar on
#294, including its index-rule subject class. Plus, because these rows change playable behavior, the protocols they
reach (see [manifest.md](manifest.md)).

## How

- Independent derivation, not the shipped script: `tools/expectations_277.py` re-implements the fill rule and reads
  each committed `-pixel.png`; `tools/nonogram.py` is its own line solver/enumerator. Neither imports
  `.github/scripts/puzzle_derive.py`. Output: [expect.json](expect.json).
- `puzzle_derive.py derive --size 15` from each committed square into a scratch file, compared byte-for-byte with the
  committed pixel; `judge --size 15` on the committed pixel. Both `verdict: pass`.
- Graphical capture on `main@58e6637` (see [reproduce.md](reproduce.md)) through the real shell, puzzle screen, and input
  events. All nine judged states were saved.

## Result

Both puzzles pass; the slice's playtest protocols pass. Nothing here is a defect.

## Notable during the run

- No fourth board: #179 is both the crossed board and the last fill. The `08`/`09` states come from it.
- #179's mark run leaves two marks in solution cells and the re-open resumes them (the board's own leave/resume
  behavior). The win was judged on that resumed board — it solved, so a wrong fill set or a clue that disagrees with its
  pixel would not hide behind those marks.
- The first capture attempt, which assumed a clean board after re-open, failed on exactly that resume behavior. That was
  a probe fault, fixed in the probe (count check); the shipped board solved in every attempt.
- Nothing was written to `game/`: the probe was removed after the run and `--import` only refreshed the gitignored cache.
