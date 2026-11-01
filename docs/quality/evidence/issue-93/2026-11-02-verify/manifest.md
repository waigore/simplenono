# Quality evaluator run — issue #93

- **Issue:** #93 Core solve loop vertical
- **Mode:** `deterministic`
- **Deliverable commit:** `dcd9a24` (`main`, the tree the implementation comment cites; run in a clean detached worktree)
- **Runner:** `issue-workflow-verify-agent` (parallel id 1), 2026-11-02, Godot 4.7.2 on macOS, headless
- **Observation source:** `integration/results.md` in this folder — six harness protocols into one run folder

## Results

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` opened the puzzle, filled every row and crossed every column one mark per frame; p95 frame time 6.94 ms over 203 frames. | ≤ 16.7 ms frame time during grid paint and navigation | pass | — | `integration/samples/paint-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame during the same `paint` run 8.24 ms over 203 frames; no frame exceeded the bar. | No hitch longer than 100 ms during grid paint | pass | — | `integration/samples/paint-hitches.ndjson` |
| `response-delay` | deterministic | I8: `ui-ack` drove open, settings intent, and back; longest acknowledgement 10.0 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793563523-ui-ack.log` |
| `crash-free` | deterministic | I9: open, solve, reset, and back all ran across `paint`, `navigate`, `ui-ack`, and `solve-reset`; no failed flow and no crashed run. The `navigate` and `kill-relaunch` exits are their own axes (I7, I10). | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |

## Not selected

- `time-to-playable` (I6) — the bar is cold launch to the interactive *gallery*; the gallery is #94. The harness's `app-start` row measures the shell home stand-in, which is not this epic's product outcome.
- `transition-latency` (I7) — gallery↔puzzle, puzzle→result, and result→gallery are #94/#95. The epic owns only the open leg; the harness fails I7 on the missing result screen, which this deliverable cannot change.
- `resume-after-failure` (I10), `save-survives`, `failed-write` — progress persistence is #96 (ADR-0002); the epic is explicitly out of scope for save and leave/resume.
- `runtime-signals` (I11) — the S1–S5 seams and S4 telemetry are #163's deliverable; the epic adds no signal source or removal.
- N/A accessibility and localization axes are not scored.

## Bar and limits

All four selected axes are integration-level and observed from the harness's headless samples on this machine; the frame and hitch numbers are sample observations, not device-tier certification. `paint` covers grid paint and navigation one mark per frame; `ui-ack` measures open/settings-intent/back acknowledgement, not the settings screen (#95) or pause (#96) themselves.
