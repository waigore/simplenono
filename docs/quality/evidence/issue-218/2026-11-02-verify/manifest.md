# Quality evaluator run — issue #218

- **Issue:** #218 Result screen ends on a blank S1 Default when a picture is missing (`type:defect`)
- **Mode:** `deterministic`
- **Deliverable commit:** `dafd4696d0670fad88feba310290b3cbfbb717af` (`main`, squash of PR #223). The runs below were executed on the tree-identical branch commit `6f7264fc71f658d6b03d6dde5e65904dc6770f3c` (`git rev-parse 6f7264f^{tree}` == `git rev-parse dafd469^{tree}`).
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 on macOS, headless
- **Observation source:** [`integration/results.md`](integration/results.md), from three sequential runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  (`paint`, `navigate`, `solve-reset`).

Selected axes are the Applies deterministic axes this deliverable can move: the reveal now paints a held layer for the
whole chain (frame sampling across the reveal), and the solve → result → back surface it changes (the navigation legs
and the open/solve/reset/back flows).

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 6.94 ms over 203 frames; `navigate` gallery p95 7.14 ms over 77 frames, reveal p95 6.94 ms over 173 frames (all windows 6.94 ms over 250). | ≤ 16.7 ms frame time during grid paint and navigation | pass | — | `integration/samples/paint-samples.ndjson`, `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 7.58 ms (`paint`, 203 frames) and 8.33 ms (`navigate`, 250 frames); no hitch above 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | `integration/samples/paint-hitches.ndjson`, `integration/samples/navigate-hitches.ndjson` (both empty) |
| `transition-latency` | deterministic | I7: longest of `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` is 291.5 ms. | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | pass | — | `integration/logs/harness-1793575176-navigate.log` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran across `paint`, `navigate`, and `solve-reset`; no failed flow and no crashed run. | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |

## Not selected

- `time-to-playable` (I6) — the launch target is unchanged; no app-start run in this folder.
- `response-delay` (I8) — the change is the reveal's paint chain, not an open/settings/Back acknowledgement; C1 still
  opens only after the two stages (US1.3) and the stage lengths are unchanged.
- `resume-after-failure` (I10), `save-survives`, `failed-write` — no `user://` write or resume path changed.
- `runtime-signals` (I11) — no telemetry source added or removed.
- N/A accessibility and localization axes are not scored.

## Cross-reference

- No cataloged assets changed; `review-asset` N/A.
- `review-code`: **Pass**, no must-fix findings — [`review-code.md`](review-code.md).
- Independent checks, reveal probe, mockup comparison, and advisory notes — [`checks.md`](checks.md).

## Verdict

`Pass` — every selected Applies deterministic axis is observed and within its bar, and no row is `fail` or `blocked`.
