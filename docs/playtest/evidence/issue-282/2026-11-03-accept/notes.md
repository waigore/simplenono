# Notes — issue #282 acceptance run

## What was judged

The slice's single acceptance criterion: each of pack-196, pack-197, pack-198, and pack-199 passes every item of the
shared picture bar on #294. Plus, because these rows change playable behavior, the protocols they reach (see
[manifest.md](manifest.md)).

Subject classes are **not** an acceptance condition: the product owner dropped the per-puzzle class on #486 (option 3,
2026-11-03). The index-rule class is recorded below for the record only.

## How

- Independent derivation, not the shipped script: `tools/expectations_282.py` re-implements the fill rule and reads each
  committed `-pixel.png`; `tools/nonogram.py` is its own line solver/enumerator (`SIZE = 20`). Neither imports
  `.github/scripts/puzzle_derive.py`. Output: [expect.json](expect.json).
- `puzzle_derive.py derive --size 20` from each committed square into a scratch file, compared byte-for-byte with the
  committed pixel; `judge --size 20` on the committed pixel. Both `verdict: pass` for all four.
- Graphical capture on `1b5dbc9` (see [reproduce.md](reproduce.md)) through the real shell, puzzle screen, and input
  events. All nine judged states were saved from this run.

## Result

All four puzzles pass the bar; the slice's playtest protocols pass. Nothing here is a defect.

| Puzzle | Filled (band 100–180) | Solutions | Line logic | Derive byte-identical | Masses / enclosed | Warm |
|--------|----------------------:|----------:|------------|-----------------------|-------------------|------|
| pack-196 | 112 | 1 | solved | yes | [92, 20] / 0 | 0.00 % |
| pack-197 | 139 | 1 | solved | yes | [139] / 0 | 0.00 % |
| pack-198 | 173 | 1 | solved | yes | [103, 70] / 0 | 0.00 % |
| pack-199 | 148 | 1 | solved | yes | [148] / 30 | 0.00 % |

Index-rule class (guidance only, #486 option 3): pack-196 multi-subject and/or holed, pack-197 single-subject,
pack-198 multi-subject and/or holed, pack-199 multi-subject and/or holed. Measured structure agrees: pack-197 is one
solid mass, pack-196 and pack-198 two masses, pack-199 one mass enclosing 30 background cells in two cavities.

## Notable during the run

- **The reason the earlier accept run sent this back is now measured.** `PTD-ready-and-marks` P2 is judged on the real
  data, not assumed: pack-197 carries 6 empty-clue rows and 9 empty-clue columns, so 246 of its 400 cells auto-cross when
  Ready completes — 0 crossed during the beat. The collected state is exactly the empty-clue lines' cells, and the board
  becomes in progress without a mark. S3 (wrong fill stays playable, no fail state) and S4 (pause freezes elapsed, blocks
  marks, resume re-allows them) also pass on this board.
- pack-199's result shot ends the two-stage morph (`finish_morph()`) before capture, the same way the solve shot does, so
  the judged state is the deciding frame and not a blur mid-fade.
- The gallery shows #196 Done with its own picture tile while #192–#195 and #197–#199 still carry the seeded silhouette —
  those rows belong to slices that have not shipped their pixels. That is expected, not a miss.
- Nothing was written to `game/`: the probe was removed after the run and `--import` only refreshed the gitignored cache.
- The deterministic quality record for this deliverable (`game/` at `1b5dbc9`, `time-to-playable` 284.3 ms ≤ 3 s) is the
  verification run in [`docs/quality/evidence/issue-282/2026-11-03-verify/`](https://github.com/waigore/simplenono/blob/evidence/282-deterministic/docs/quality/evidence/issue-282/2026-11-03-verify/manifest.md).
  Its evidence PR #490 was open at the time of this run; `game/` on that branch is identical to `1b5dbc9`, so the record
  covers this tree.
