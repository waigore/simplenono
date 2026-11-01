# Quality evaluator run — issue #191

- **Issue:** #191 Shell audio, haptics, and the asset resolver (`CMP-shell` R4/R6)
- **Mode:** `deterministic`
- **Deliverable commit:** `cd08f790b40f3f68e6d9c2b5f4124a564f05b2e5` (PR [#196](https://github.com/waigore/simplenono/pull/196), merged; `main` HEAD at verification)
- **Runner:** `issue-workflow-verify-agent` (parallel id 1), 2026-11-02, clean detached worktree at the deliverable commit, Godot 4.7.2 on macOS, headless
- **Observation source:** [`integration/results.md`](integration/results.md) — six harness protocols into one run folder

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

## Bar and limits

All four selected axes are integration-level and observed from the harness's headless samples on this machine; the frame and hitch numbers are sample observations, not device-tier certification. `paint` covers grid paint and navigation one mark per frame; `ui-ack` measures open/settings-intent/back acknowledgement, not the settings screen (#95) or pause (#96) themselves. Audible and haptic output is not observed here: the deliverable's unit tests assert it through injected sinks.
