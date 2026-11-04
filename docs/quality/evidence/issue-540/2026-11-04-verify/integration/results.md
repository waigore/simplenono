# Integration harness run

- **Run folder:** `/tmp/opencode/qe540-pr`
- **Generated:** 1793793852
- **Protocols run:** navigate, paint, solve-reset, ui-ack
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | protocol not run in this folder | <= 3 s | not run | - |
| paint | I1 | frame-time | p95 frame time 16.01 ms over 203 frames | <= 16.7 ms | pass | integration/samples/paint-samples.ndjson |
| paint | I2 | hitch-bound | longest frame 23.41 ms over 203 frames | <= 100 ms | pass | integration/samples/paint-hitches.ndjson |
| paint | I9 | crash-free | flows ran: back, open, reset, solve; flow failed: solve | No crash across open, solve, reset, and back | fail | integration/results/paint.json |
| navigate | I1 | frame-time | p95 frame time gallery 6.94 ms over 72 frames, reveal 6.94 ms over 451 frames (all windows 6.94 ms) over 523 frames | <= 16.7 ms | pass | integration/samples/navigate-samples.ndjson |
| navigate | I2 | hitch-bound | longest frame 39.43 ms over 523 frames | <= 100 ms | pass | integration/samples/navigate-hitches.ndjson |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 2211.0 ms; protocol failed: puzzle-result: filling the solution did not solve the puzzle | <= 500 ms | fail | integration/logs/harness-1793793834-navigate.log |
| navigate | I9 | crash-free | flows ran: back, open, reset, solve; flow failed: solve | No crash across open, solve, reset, and back | fail | integration/results/navigate.json |
| ui-ack | I8 | response-delay | longest acknowledgement among ack:back, ack:open, ack:settings: 28.8 ms | <= 500 ms | pass | integration/logs/harness-1793793846-ui-ack.log |
| ui-ack | I9 | crash-free | flows ran: back, open, reset, solve; flow failed: solve | No crash across open, solve, reset, and back | fail | integration/results/ui-ack.json |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve; flow failed: solve | No crash across open, solve, reset, and back | fail | integration/results/solve-reset.json |
| kill-relaunch | I10 | resume-after-failure | protocol not run in this folder | Next launch is gallery; reopen restores marks and elapsed | not run | - |
| self-test | - | - | protocol not run in this folder | - | not run | - |

