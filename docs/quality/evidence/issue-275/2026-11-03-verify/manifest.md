# Quality evaluator run — issue #275

- **Issue:** #275 Puzzle pictures pack-170–pack-173 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `cf9b4d1` (`task/275-pack-170-173-pictures`, PR #453, head at this run; not merged)
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  after a clean `--import` of the PR head

Only `time-to-playable` is selected. This deliverable adds eight static picture files and rewrites four pack rows' fills
and clues; it changes no runtime code, so no crash, resume, signal, or save axis can move. It does put two new
`CompressedTexture2D` assets per puzzle on the gallery path, so launch-to-interactive-gallery is the one Applies
deterministic axis this deliverable can reach.

No existing record covers `game/` at `cf9b4d1` (the closest, #267 `62a3d52`, differs by this slice's `game/data/pack.json`
rows and picture files), so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 1890.5 ms at `cf9b4d1` after a clean re-import. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793678275-app-start.log` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable adds data and assets only.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the `app-start` run loaded the shell with the new rows and pictures.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.

## Extra protocols (context only, not this run's rows)

`paint`, `navigate`, and `solve-reset` were also run into this folder to confirm the deliverable does not crash the shell.
`solve-reset` passed. `paint` I1 (p95 22.22 ms) and `navigate` I7 (504.8 ms) read fail; neither is a `time-to-playable` row,
neither is reached by a code path this deliverable changes, and headless Linux frame timings are not the bar's
supported-device observation.
