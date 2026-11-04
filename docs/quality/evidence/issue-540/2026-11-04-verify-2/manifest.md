# Quality evaluator run — issue #540

- **Issue:** #540 Mobile gallery tiles: cramped spacing, overlapping labels, uncentered thumbnails (`type:defect`)
- **Mode:** `deterministic`
- **Deliverable commit:** `0f626cd` (`origin/main`, the shipped tree at verification). The issue's fix is PR #547 → `3762da9`; `7025a32` (#548) added the earlier record, and `0f626cd` (#549) changes `gallery_tile.gd` (touch scroll only), so no earlier record's `game/` tree matches this one.
- **Evaluated:** 2026-11-04 by `issue-workflow-verify-agent` (parallel id 2), Godot 4.7.2 stable on macOS (darwin), quiet host (load average 2.0–2.4).
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `paint`, `navigate`, `ui-ack`, and `solve-reset`, each under a fresh `HOME` (`user://`).

The deliverable is gallery layout code: `gallery.gd` derives the R2 column breakpoint, page margin, and
tile gap from the frame, `gallery_tile.gd` clips tile labels (and, since #549, routes a touch drag to the
scroll container), `gallery.tscn` sets the starting margin. The selected axes are the Applies deterministic
axes those changes can move: `frame-time` and `hitch-bound` on the gallery window of grid paint (I1, I2),
`transition-latency` for the gallery↔puzzle↔result legs (I7), `response-delay` for the gallery's open and
settings legs (I8), and `crash-free` for the open/solve/reset/back flows (I9).

No existing record covers `game/` at `0f626cd`: #540's earlier record covers `e05e4e0`/`3762da9`, and
`git diff 3762da9 0f626cd -- game/` is non-empty (`gallery_tile.gd`, `scroll_drag_release.gd`,
`test_touch_input.gd`). This run is therefore a fresh record rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 6.94 ms over 203 frames; `navigate` p95 6.94 ms with gallery 6.94 ms over 77 frames and reveal 6.94 ms over 162 frames over 239 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 7.19 ms (`paint`, 203 frames) and 7.46 ms (`navigate`, 239 frames). | No hitch longer than 100 ms during grid paint | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 208.5 ms. | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793800227-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 7.8 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793800229-ui-ack.log` |
| `crash-free` | deterministic | I9: flows `open`, `solve`, `back`, `reset` all ran in `solve-reset`; no failed flow, no crashed run. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/solve-reset.json` |

The `crash-free` row is judged at run level, as the harness README defines it: every I9 flow must have run
in a protocol in the folder without a failed flow. `solve-reset` ran all four; no protocol in this folder
records a failed flow or a crash.

## `integration/results.md` row defect (harness, not this deliverable)

The generated summary prints the *run-level* `crash-free` observation on every protocol row that claims I9,
so the `paint`, `navigate`, and `ui-ack` rows also read "flows ran: back, open, reset, solve". The protocol
JSONs are right: `paint` ran only `open`, `navigate` and `ui-ack` only `open` and `back`. The table above
cites `solve-reset.json` for I9. This is harness paperwork with no effect on a result; it is not filed as a
task here because no row's pass/fail changes.

## Not selected

- `time-to-playable` (I6) — no launch path changed.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- Save durability (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
