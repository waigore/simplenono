# Quality evaluator run — issue #270

- **Issue:** #270 Puzzle pictures pack-150–pack-153 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `631846a` (`main` at this run; its `game/` tree is `44e842d`, the tree acceptance asked for —
  `git rev-parse 631846a:game` = `git rev-parse d688934:game`)
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<this folder>`
  after a clean `--import` of `main@631846a`

Only `time-to-playable` is selected. This deliverable adds eight static picture files and rewrites four pack rows' fills
and clues; it changes no runtime code, so no crash, resume, signal, or save axis can move. It does put two new
`CompressedTexture2D` assets per puzzle on the gallery path, so launch-to-interactive-gallery is the one Applies
deterministic axis this deliverable can reach.

No existing record covers `game/` at `44e842d`: the closest, #344 at `90a76bd`, records `game/` tree `55d7f48e`, which
differs by this slice's pictures, catalog entries, and `game/data/pack.json` rows (and later slices). This is a fresh run,
not a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 1996.1 ms at `631846a` after a clean re-import. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793678926-app-start.log` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable adds data and assets only.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the `app-start` run above completed all five steps without a crash.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## Run limit

The 1996.1 ms launch figure is a cold headless launch on this Linux runner with no GPU; it is well inside the 3 s bar but
is not a mid-range-phone measurement. The other protocols were not run because this deliverable reaches none of their
axes.

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty.
