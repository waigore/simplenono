# Integration harness run

- **Run folder:** `/tmp/opencode/final706b`
- **Generated:** 1793970977
- **Protocols run:** app-start, navigate, paint, solve-reset, ui-ack
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | cold launch to the interactive shell home (menu): 2782.2 ms | <= 3 s | pass | integration/logs/harness-1793970954-app-start.log |
| paint | I1 | frame-time | p95 frame time 25.00 ms over 203 frames | <= 16.7 ms | fail | integration/samples/paint-samples.ndjson |
| paint | I2 | hitch-bound | longest frame 39.43 ms over 203 frames | <= 100 ms | pass | integration/samples/paint-hitches.ndjson |
| paint | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/paint.json |
| navigate | I1 | frame-time | p95 frame time gallery 8.33 ms over 72 frames, reveal 16.67 ms over 173 frames (all windows 16.67 ms) over 245 frames | <= 16.7 ms | pass | integration/samples/navigate-samples.ndjson |
| navigate | I2 | hitch-bound | longest frame 61.73 ms over 245 frames | <= 100 ms | pass | integration/samples/navigate-hitches.ndjson |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 695.6 ms | <= 500 ms | fail | integration/logs/harness-1793970964-navigate.log |
| navigate | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/navigate.json |
| ui-ack | I8 | response-delay | longest acknowledgement among ack:back, ack:open, ack:settings: 28.4 ms | <= 500 ms | pass | integration/logs/harness-1793970969-ui-ack.log |
| ui-ack | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/ui-ack.json |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/solve-reset.json |
| self-test | - | - | protocol not run in this folder | - | not run | - |

