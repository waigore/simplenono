# Integration harness run

- **Run folder:** `/tmp/opencode/qe539-pr/baseline`
- **Generated:** 1793795235
- **Protocols run:** navigate
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | protocol not run in this folder | <= 3 s | not run | - |
| paint | I1 | frame-time | protocol not run in this folder | <= 16.7 ms | not run | - |
| paint | I2 | hitch-bound | protocol not run in this folder | <= 100 ms | not run | - |
| paint | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| navigate | I1 | frame-time | p95 frame time gallery 7.60 ms over 74 frames, reveal 12.50 ms over 162 frames (all windows 12.25 ms) over 236 frames | <= 16.7 ms | pass | integration/samples/navigate-samples.ndjson |
| navigate | I2 | hitch-bound | longest frame 28.98 ms over 236 frames | <= 100 ms | pass | integration/samples/navigate-hitches.ndjson |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 376.9 ms; protocol failed: gallery-mobile: gallery picture aspect at 390x844 is 0.000, expected 1 | <= 500 ms | fail | integration/logs/harness-1793795233-navigate.log |
| navigate | I9 | crash-free | I9 flows missing: reset (flows ran: back, open, solve) | No crash across open, solve, reset, and back | fail | integration/results/navigate.json |
| ui-ack | I8 | response-delay | protocol not run in this folder | <= 500 ms | not run | - |
| ui-ack | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| solve-reset | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| kill-relaunch | I10 | resume-after-failure | protocol not run in this folder | Next launch is gallery; reopen restores marks and elapsed | not run | - |
| self-test | - | - | protocol not run in this folder | - | not run | - |

