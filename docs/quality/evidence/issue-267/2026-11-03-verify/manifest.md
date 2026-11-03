# Quality evaluator run — issue #267

- **Issue:** #267 Puzzle pictures pack-138–pack-141 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `62a3d52` (`main` at the time of this run; the slice landed in PR #409 `a9d559e` and repair PR #439 `c2b1a04`). Measured two ways: `game/` at `62a3d52` (primary, written into this folder) and `game/` at `c2b1a04`, the slice's merge, in a detached worktree (`1819.0`–`1839.0 ms`, also pass).
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<this folder>`

Only `time-to-playable` is selected. This deliverable adds eight static picture files and rewrites four pack rows' fills
and clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or save axis
can move. It does put two new `CompressedTexture2D` assets per puzzle on the gallery path — `shell.gd` `_picture_for`
resolves each visible tile's `picture-id` through the resolver at shell setup — so launch-to-interactive-gallery is the
one Applies deterministic axis this deliverable can reach.

The eight catalogue ids on the four slice rows (pack-138 `01a17720-ca00-7088-…` / `…-70b6-…`, pack-139
`…-72a0-…` / `…-7301-…`, pack-140 `…-726b-…` / `…-7160-…`, pack-141 `…-7025-…` / `…-70f3-…`) were each resolved
through the same resolver in this build: `has=true`, decoded, squares 1024×1024 and pixels 15×15. So the launch timed
here loads this deliverable's pictures.

The slice content is identical at both measured commits: `git diff c2b1a04 62a3d52` touches none of the eight picture
files, none of their `.import` sidecars, and none of the pack-138–pack-141 rows of `game/data/pack.json`; the only
`game/` movement is later picture slices (pack-144, pack-145, pack-162–pack-169).

No existing record covered `game/` at `62a3d52` or at `c2b1a04` (`git diff <recorded> <commit> -- game/` was non-empty
for every earlier `docs/quality/evidence/*` record, the closest being #427 `08ba1d5` at 41 paths), so this record is a
fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 1970.7 ms at `62a3d52` after a clean re-import (2063.8 ms in the first, warm-import run), and 1839.0 ms for the same slice content at its merge `c2b1a04`. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793676821-app-start.log` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable does not reach those paths.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the deliverable adds data the pack loader already accepts (the `app-start`
  run above loaded the shell home with the new rows and pictures, `crashed: false`).
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.
