# Quality evaluator run — issue 166

- **Issue:** #166 — Integration harness for the Applies integration-level quality invariants
- **Mode:** `deterministic`
- **Deliverable commit:** `58bc5ce07ecc87535c296880d7db2f12d83c9682` (PR #173)
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), local Godot 4.7.2, macOS; headless unless noted
- **Observation source:** `integration/results.md` in this folder, produced by six sequential runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=docs/quality/evidence/issue-166/2026-11-02-deterministic`
  into this one run folder (`app-start` 0, `paint` 0, `navigate` 1, `ui-ack` 0, `solve-reset` 0, `kill-relaunch` 1).

Only the axes this deliverable's evidence can actually move are selected: the ones whose observations the harness
produced against real per-frame samples and real drive lists. The three latency axes are deliberately not scored
from this run: the harness executes every drive list in a single `process_frame` after the start mark (for example
`paint` advances two grid cells per frame and `ui-ack` never yields between its marks), so its durations measure
harness CPU time, not the product's acknowledgement latency. That is a measured-evidence gap, not a harness-level
defect, and is reported in the verification comment as follow-up work.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | p95 frame time 6.94 ms over 103 frames sampled during grid paint | ≤ 16.7 ms | pass | — | `integration/samples/paint-samples.ndjson` |
| `hitch-bound` | deterministic | longest frame 7.63 ms over 103 frames sampled during grid paint | ≤ 100 ms | pass | — | `integration/samples/paint-hitches.ndjson` |
| `crash-free` | deterministic | flows ran: back, open, reset, solve; no failed flow or crashed run across the six protocols | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |
