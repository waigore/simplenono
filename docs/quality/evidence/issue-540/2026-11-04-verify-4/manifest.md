# Quality evaluator run — issue #540

- **Issue:** #540 Mobile gallery tiles: cramped spacing, overlapping labels, uncentered thumbnails (`type:defect`)
- **Mode:** `deterministic`
- **Deliverable commit:** `a8811a3` (`origin/main` at verification, 2026-11-04). The issue's fix is PR #547 → `3762da9` (spacing, label clipping, picture square), with `0f626cd` (#549, touch scroll) and `26df61e` (#551, export comment) after; the acceptance-reopened tile-body padding landed in the same window as merged PR #561 → `a8811a3` (defect #557's own fix, same symptom inside #540's "clear per-tile metadata"). #540's deliverable PR #560 proposed the same fix and was closed as superseded, so the shipped tree is this one. `git diff 26df61e a8811a3 -- game/` is not empty, so no earlier record covers this `game/` tree — the nearest, `2026-11-04-verify-3`, records `26df61e`, and this is a fresh run rather than a reuse.
- **Evaluated:** 2026-11-04 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on macOS (darwin), quiet host (load average 2.9–3.0 on 10 cores).
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `paint`, `navigate`, `ui-ack`, and `solve-reset`, each under a fresh `HOME` (`user://`).

The deliverable is gallery layout code: `gallery.gd` derives R2's columns, page margin, tile gap, and tile body
padding (`tile_padding()`) from the frame and applies them on layout and rebuild; `gallery_tile.gd` clips tile
labels and insets the metadata holder on all four sides (`set_body_padding()`) with the Reset holder following
the same value and a deferred picture re-square. The selected axes are the Applies deterministic axes these
changes can move: `frame-time` and `hitch-bound` on the gallery window of grid paint (I1, I2),
`transition-latency` for the gallery↔puzzle↔result legs (I7), `response-delay` for the gallery's open and
settings legs (I8), and `crash-free` for the open/solve/reset/back flows (I9).

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 7.14 ms over 203 frames; `navigate` p95 with gallery 6.94 ms over 77 frames and reveal 6.94 ms over 161 frames (all windows 6.94 ms) over 238 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 13.18 ms (`paint`, 203 frames) and 7.21 ms (`navigate`, 238 frames). | No hitch longer than 100 ms during grid paint | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 202.5 ms. | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793803792-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 6.1 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793803798-ui-ack.log` |
| `crash-free` | deterministic | I9: flows `open`, `solve`, `back`, `reset` all ran in `solve-reset` (`flows_ok` in `solve-reset.json`); no failed flow, no crashed run. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/solve-reset.json` |

The `crash-free` row is judged at run level, as the harness README defines it: every I9 flow must have run in a
protocol in the folder without a failed flow. `solve-reset` ran all four; no protocol here records a failed flow
or a crash.

## `integration/results.md` row defect (harness, not this deliverable)

The generated summary prints the run-level `crash-free` observation on every protocol row that claims I9, so the
`paint`, `navigate`, and `ui-ack` rows also read "flows ran: back, open, reset, solve". The protocol JSONs are
right (`paint` ran `open`; `navigate` ran `open`, `solve`, `back`; `ui-ack` ran `open` and `back`). The table above
cites `solve-reset.json` for I9. This is harness paperwork with no effect on a result.

## Not selected

- `time-to-playable` (I6) — no launch path changed.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
