# Quality evaluator run — issue #255

- **Issue:** #255 Puzzle pictures pack-090–pack-093 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `29a9295` (`main` under acceptance; the slice landed at PR #381's squash `1e56ac1`, and
  `pack-090`–`pack-093` are byte-identical from `1e56ac1` to `29a9295`, so this tree plays exactly the delivered rows)
- **Evaluated:** 2026-11-03 by `issue-workflow-accept-agent` (parallel id 1) — **reused**, not re-run
- **Observation source:** reuse of [`docs/quality/evidence/issue-258/2026-11-03-verify/manifest.md`](../../issue-258/2026-11-03-verify/manifest.md),
  recorded at `84082e1`

`time-to-playable` is the only Applies deterministic axis this deliverable can reach: it adds two
`CompressedTexture2D` assets per puzzle to the gallery path (`gallery.gd` `_picture_for` resolves each visible tile's
`picture-id` through the manifest at shell setup) and changes no runtime code. The same selection, and the same
rationale for leaving every other axis unselected, is in the reused record.

## Reuse check

`git diff 84082e1 29a9295 -- game/` is **not** empty: it lists 161 paths. Every one of them is a later slice's own
assets or its own pack rows — `game/assets/puzzle-pictures/pack-*.png` (+ `.import`) for the slices that landed
after `84082e1`, and their `game/data/pack.json` rows. The reused record's own scope is the same shape as this one
(no runtime code; pictures plus pack data).

No other recorded `deterministic` run covers `game/` at `29a9295` either: every slice's record is measured at its own
squash, and each later slice adds its own pictures and rows. The row is therefore **blocked**, and acceptance records
that as a wait on the verify stage rather than as a pass. It does not change the acceptance outcome:
`time-to-playable` is a headless launch check that no picture slice can move beyond asset-load size, and the graphical
acceptance run in [`docs/playtest/evidence/issue-255/2026-11-03-accept-graphical/`](../../../../playtest/evidence/issue-255/2026-11-03-accept-graphical/manifest.md)
loads all 200 puzzles with 0 rejected at `29a9295`.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | Reused record: I6 cold launch to the interactive shell home (gallery) 293.5 ms at `84082e1`. | Cold launch to interactive gallery ≤ 3 s | blocked | `reuse-does-not-cover-game-tree` (`git diff 84082e1 29a9295 -- game/` is 161 paths) | `docs/quality/evidence/issue-258/2026-11-03-verify/manifest.md` |

## llm-judge

Not applicable. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and its domain axes list is `None`. No judge record exists to read.
