# Selected axes — issue #191

## Results

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` opened the puzzle, filled every row and crossed every column one mark per frame — now with the mark tick and haptic path live — p95 frame time 6.94 ms over 203 frames. | ≤ 16.7 ms frame time during grid paint and navigation | pass | — | `integration/samples/paint-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame during the same `paint` run 7.60 ms over 203 frames; no frame exceeded the bar. | No hitch longer than 100 ms during grid paint | pass | — | `integration/samples/paint-hitches.ndjson` |
| `response-delay` | deterministic | I8: `ui-ack` drove open, settings intent, and back — open now constructs the resolver (manifest read happens at app start, not here) and starts the bed — longest acknowledgement 8.1 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793565025-ui-ack.log` |
| `crash-free` | deterministic | I9: open, solve, reset, and back all ran across `paint`, `navigate`, `ui-ack`, and `solve-reset`, including the solve sting and bed stop; no failed flow and no crashed run. The `navigate` and `kill-relaunch` exits are their own axes (I7, I10). | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |

## Not selected

- `time-to-playable` (I6) — the bar is cold launch to the interactive *gallery*; the gallery is #94. The delivered startup work (manifest read plus three tick preloads) is visible in the `app-start` context row at 198.6 ms for the shell home stand-in, but that stand-in is not this deliverable's product outcome.
- `transition-latency` (I7) — gallery↔puzzle, puzzle→result, and result→gallery are #94/#95. The harness fails I7 on the missing result screen, which this deliverable does not build or change.
- `resume-after-failure` (I10) — progress persistence is #96; the harness fails I10 on missing mark/elapsed restore, unchanged by this deliverable.
- `save-survives`, `failed-write` — the deliverable adds no `user://` write; the two session flags are memory-only.
- `runtime-signals` (I11) — this deliverable adds no telemetry source or removal; the S1–S5 seams and S4 telemetry are #163's.
- N/A accessibility and localization axes are not scored.
