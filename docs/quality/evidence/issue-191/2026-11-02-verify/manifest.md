# Quality evaluator run — issue #191

- **Issue:** #191 Shell audio, haptics, and the asset resolver (`CMP-shell` R4/R6)
- **Mode:** `deterministic`
- **Deliverable commit:** `cd08f790b40f3f68e6d9c2b5f4124a564f05b2e5` (PR [#196](https://github.com/waigore/simplenono/pull/196), merged; `main` HEAD at verification)
- **Runner:** `issue-workflow-verify-agent` (parallel id 1), 2026-11-02, clean detached worktree at the deliverable commit, Godot 4.7.2 on macOS, headless
- **Observation source:** [`integration/results.md`](integration/results.md) — six harness protocols into one run folder

## Results

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` filled every row and crossed every column one mark per frame, now with the tick/haptic path live; p95 6.94 ms over 203 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | `integration/samples/paint-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame in the same run 7.60 ms over 203 frames; none exceeded the bar. | No hitch longer than 100 ms | pass | — | `integration/samples/paint-hitches.ndjson` |
| `response-delay` | deterministic | I8: `ui-ack` open (now starting the bed), settings intent, and back; longest acknowledgement 8.1 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793565025-ui-ack.log` |
| `crash-free` | deterministic | I9: open, solve, reset, and back across `paint`, `navigate`, `ui-ack`, and `solve-reset`, including the sting and bed stop; no failed flow or crashed run. `navigate`/`kill-relaunch` exits are I7/I10. | No crash across the four flows | pass | — | `integration/results.md` |

## Not selected

- `time-to-playable` (I6) — the bar is launch to the interactive *gallery* (#94). The `app-start` context row shows 198.6 ms for the shell home stand-in, which is not this deliverable's outcome.
- `transition-latency` (I7) — gallery↔puzzle and result transitions are #94/#95; the harness fails I7 on the missing result screen, unchanged here.
- `resume-after-failure` (I10) — persistence is #96; I10 fails on missing restore, unchanged here.
- `save-survives`, `failed-write` — no `user://` write; flags are memory-only.
- `runtime-signals` (I11) — no telemetry source added or removed (#163 owns it).
- N/A accessibility and localization axes are not scored.

## Bar and limits

Selected axes are integration-level headless samples on this machine, not device-tier certification. `paint` runs one mark per frame; `ui-ack` times open/settings-intent/back, not the settings screen (#95) or pause (#96). Audible and haptic output is asserted only by the deliverable's unit tests through injected sinks.
