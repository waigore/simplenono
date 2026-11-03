# Integration harness run

- **Run folder:** `/tmp/opencode/q275`
- **Generated:** 1793678298
- **Protocols run:** app-start, navigate, paint, solve-reset
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | cold launch to the interactive shell home (gallery): 1890.5 ms | <= 3 s | pass | integration/logs/harness-1793678275-app-start.log |
| paint | I1 | frame-time | p95 frame time 22.22 ms over 203 frames | <= 16.7 ms | fail | integration/samples/paint-samples.ndjson |
| paint | I2 | hitch-bound | longest frame 29.18 ms over 203 frames | <= 100 ms | pass | integration/samples/paint-hitches.ndjson |
| paint | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/paint.json |
| navigate | I1 | frame-time | p95 frame time gallery 10.42 ms over 74 frames, reveal 18.06 ms over 162 frames (all windows 16.67 ms) over 236 frames | <= 16.7 ms | pass | integration/samples/navigate-samples.ndjson |
| navigate | I2 | hitch-bound | longest frame 20.94 ms over 236 frames | <= 100 ms | pass | integration/samples/navigate-hitches.ndjson |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 504.8 ms | <= 500 ms | fail | integration/logs/harness-1793678290-navigate.log |
| navigate | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/navigate.json |
| ui-ack | I8 | response-delay | protocol not run in this folder | <= 500 ms | not run | - |
| ui-ack | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/solve-reset.json |
| kill-relaunch | I10 | resume-after-failure | protocol not run in this folder | Next launch is gallery; reopen restores marks and elapsed | not run | - |
| self-test | - | - | protocol not run in this folder | - | not run | - |

