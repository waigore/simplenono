# Quality evaluator run — issue #97

- **Issue:** #97 End conditions & progression closing (`type:epic`, Wave 3)
- **Mode:** `deterministic`
- **Deliverable commit:** `b9c5668` (`main`, squash of PR #290). The epic's own code lands at `2dbfd93`
  (squash of PR #221, `pack_finished` in `game/records/`); only docs landed after it.
- **Evaluated:** 2026-11-02 by `issue-workflow-accept-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from five sequential runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  (`app-start`, `paint`, `navigate`, `ui-ack`, `solve-reset`).

## Why this record exists

[`docs/quality/evidence/README.md`](../../README.md) requires a record that covers
`game/` at the deliverable commit. The nearest passing record, #284's `2026-11-02-verify`, was made at
`9e1a275` — before #289 landed the shipped puzzle pictures (`game/assets/puzzle-pictures/*`,
`game/data/pack.json`), so `git diff 9e1a275 b9c5668 -- game/` is not empty and that record does not
reuse. This run re-observes the selected axes on the acceptance tree.

The epic's own deliverable (a derived progress fact plus tests) moves no timing, flow, or persistence
outcome; the selected axes are those the loaded tree carries and the acceptance playtest exercises
(open, solve, result, back to a 200/200 gallery).

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 8.33 ms over 203 frames; `navigate` p95 7.58 ms over 235 frames (gallery 73, reveal 162). | ≤ 16.7 ms frame time during grid paint and navigation | pass | — | `integration/samples/paint-samples.ndjson`, `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 11.69 ms (`paint`, 203 frames) and 20.09 ms (`navigate`, 235 frames); 0 frames above 100 ms. | No hitch longer than 100 ms during grid paint on mid-range phones | pass | — | `integration/samples/paint-hitches.ndjson`, `integration/samples/navigate-hitches.ndjson` (both empty) |
| `time-to-playable` | deterministic | I6: cold launch to the interactive gallery 1708.6 ms, pictures themed as shipped. | ≤ 3 s on mid-range phones | pass | — | `integration/logs/harness-1793592708-app-start.log` |
| `transition-latency` | deterministic | I7: longest of `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 214.1 ms. | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | pass | — | `integration/logs/harness-1793592714-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:open`, `ack:settings`, `ack:back` 27.9 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793592717-ui-ack.log` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran across `paint`, `navigate`, `ui-ack`, and `solve-reset`; no failed flow and no crashed run — including the solve that lands `END.W2`'s 200th first-solve. | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |

## Not selected

- `resume-after-failure` (I10) — kill/relaunch and marks/elapsed restore are #96; `kill-relaunch` is not run here.
- `save-survives`, `failed-write` — PR #221 adds no `user://` write; `END.W2` is a read of the existing
  record set, and `pack_finished()` writes nothing.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed by #221.

## Verdict

`Pass` — every selected Applies deterministic axis is observed and within its bar, and no row is `fail` or `blocked`.
