# Quality evaluator run — issue #95

- **Issue:** #95 Result, settings & navigation (`type:epic`)
- **Mode:** `deterministic`
- **Deliverable commit:** `dafd4696d0670fad88feba310290b3cbfbb717af` (`main`, squash of PR #223; epic delivery over #202 `71efe63`, #208 `94e6c55`, #216 `a9f8558`). The runs below were executed on `main` at `8cfb263`, whose product tree is identical to `dafd469` (that commit adds only the #218 evidence folder).
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 on macOS, headless
- **Observation source:** [`integration/results.md`](integration/results.md), from five sequential runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  (`app-start`, `paint`, `navigate`, `ui-ack`, `solve-reset`).

Selected axes are the Applies deterministic axes this deliverable can move: frame sampling across the reveal whose
terminal layer changed (`navigate` samples the solve and the morph), and the screen-flow surface the epic owns (the
cross-screen legs I7, the timed settings surface I8, and the open/solve/reset/back flows I9). This is the same
selection as the previous epic run; the acceptance-found missing-picture defect is repaired here.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 6.94 ms over 203 frames; `navigate` p95 6.94 ms (gallery window 77 frames, reveal window 173 frames; all windows 6.94 ms over 250). | ≤ 16.7 ms frame time during grid paint and navigation | pass | — | `integration/samples/paint-samples.ndjson`, `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 7.27 ms (`paint`, 203 frames) and 10.00 ms (`navigate`, 250 frames); 0 hitches above 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | `integration/samples/paint-hitches.ndjson`, `integration/samples/navigate-hitches.ndjson` (both empty) |
| `transition-latency` | deterministic | I7: longest of `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` is 287.9 ms; every leg product-acknowledged (no `driver_time` rows). | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | pass | — | `integration/logs/harness-1793575593-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` is 7.8 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793575595-ui-ack.log` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran across `paint`, `navigate`, `ui-ack`, and `solve-reset`; no failed flow and no crashed run. | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |

## Not selected

- `time-to-playable` (I6) — cold launch is #94's outcome; the `app-start` row (259.6 ms) is context only.
- `resume-after-failure` (I10) — kill/relaunch and restore are #96; that protocol is not run in this folder.
- `save-survives`, `failed-write` — no `user://` write or persistence path changed; the session flags stay memory-only.
- `runtime-signals` (I11) — no telemetry source added or removed.
- N/A accessibility and localization axes are not scored.

## Cross-reference

- No cataloged assets changed; `review-asset` N/A.
- `review-code`: **Pass**, no must-fix findings — [`review-code.md`](review-code.md).
- Independent checks, missing-picture probe, and mockup gate — [`checks.md`](checks.md).

## Verdict

`Pass` — every selected Applies deterministic axis is observed and within its bar, and no row is `fail` or `blocked`.
