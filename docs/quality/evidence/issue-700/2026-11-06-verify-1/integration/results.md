# Integration harness run

- **Run folder:** `/tmp/opencode/verify-700/docs/quality/evidence/issue-700/2026-11-06-verify-1`
- **Generated:** 1793974699
- **Protocols run:** navigate
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | protocol not run in this folder | <= 3 s | not run | - |
| paint | I1 | frame-time | protocol not run in this folder | <= 16.7 ms | not run | - |
| paint | I2 | hitch-bound | protocol not run in this folder | <= 100 ms | not run | - |
| paint | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| navigate | I1 | frame-time | p95 frame time gallery 16.93 ms over 113 frames, reveal 6.94 ms over 133 frames (all windows 16.67 ms) over 246 frames | <= 16.7 ms | pass | integration/samples/navigate-samples.ndjson |
| navigate | I2 | hitch-bound | longest frame 54.84 ms over 246 frames | <= 100 ms | pass | integration/samples/navigate-hitches.ndjson |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 63.8 ms | <= 500 ms | pass | integration/logs/harness-1793974695-navigate.log |
| navigate | I9 | crash-free | I9 flows missing: reset (flows ran: back, open, solve) | No crash across open, solve, reset, and back | fail | integration/results/navigate.json |
| ui-ack | I8 | response-delay | protocol not run in this folder | <= 500 ms | not run | - |
| ui-ack | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| solve-reset | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| self-test | - | - | protocol not run in this folder | - | not run | - |

