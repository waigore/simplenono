# Quality evaluator run — issue #95

- **Issue:** #95 Result, settings & navigation
- **Mode:** `deterministic`
- **Deliverable commit:** `a9f8558591dd6fe8bc8f4e70d653f9a326577d3e` (`main`, PR #216 `Give the result reveal one clock`; epic delivery over #202 `04de211` and #208 `94e6c55`). The runs below were executed on the tree-identical commit `40a05f6` (`git rev-parse 40a05f6^{tree}` == `a9f8558^{tree}`); `main` has since advanced only by the #94 evidence folder.
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 on macOS, headless
- **Observation source:** `integration/results.md`, from five sequential runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<folder>`
  into this one folder (`app-start` 0, `paint` 0, `navigate` 0, `ui-ack` 0, `solve-reset` 0).

Selected axes are the Applies deterministic axes this deliverable can move: the repaired reveal clock, frame sampling
across that reveal (`navigate` now claims I1/I2), the cross-screen legs (I7), the timed settings surface (I8), and
the open/solve/reset/back flows (I9). The prior run's `frame-time`/`hitch-bound` `blocked` gap is closed:
`navigate-samples.ndjson` holds 173 frames across the solve and the three-layer morph.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 6.94 ms over 203 frames; `navigate` p95 6.94 ms over 173 frames sampled across the solve and the result reveal (`UI-result` S2/S3). | ≤ 16.7 ms frame time during grid paint and navigation | pass | — | `integration/samples/navigate-samples.ndjson`, `integration/samples/paint-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 8.06 ms (`navigate`, 173 frames) and 7.93 ms (`paint`, 203 frames); 0 hitches above 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | `integration/samples/navigate-hitches.ndjson` (empty: no hitch) |
| `transition-latency` | deterministic | I7: longest of `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` is 290.1 ms; every leg is product-acknowledged (no `driver_time` rows). | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | pass | — | `integration/logs/harness-1793572330-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` is 7.8 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793572332-ui-ack.log` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran across `paint`, `navigate`, `ui-ack`, and `solve-reset`; no failed flow and no crashed run. | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |

## Not selected

- `time-to-playable` (I6) — cold launch is #94's outcome; the `app-start` row (249.1 ms) is context only.
- `resume-after-failure` (I10) — mark/elapsed restore is #96.
- `save-survives`, `failed-write` — no `user://` write here; the two session flags stay memory-only.
- `runtime-signals` (I11) — no telemetry source is added or removed.
- N/A accessibility and localization axes are not scored.

## Cross-reference

- No cataloged assets changed; `review-asset` N/A.
- `review-code`: **Pass**, no must-fix findings — [`review-code.md`](review-code.md).
- Independent checks and run commands — [`checks.md`](checks.md). Reveal-clock probe and test-gap proof — [`rationale.md`](rationale.md).

## Verdict

`Pass` — every selected Applies deterministic axis is observed and within its bar, and no row is `fail` or `blocked`.
