# Integration harness run

- **Run folder:** `/tmp/opencode/verify-693/run`
- **Generated:** 1793962953
- **Protocols run:** app-start, kill-relaunch, navigate, paint, solve-reset, ui-ack
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | cold launch to the interactive shell home (menu): 2465.5 ms | <= 3 s | pass | integration/logs/harness-1793962911-app-start.log |
| paint | I1 | frame-time | p95 frame time 25.00 ms over 203 frames | <= 16.7 ms | fail | integration/samples/paint-samples.ndjson |
| paint | I2 | hitch-bound | longest frame 47.91 ms over 203 frames | <= 100 ms | pass | integration/samples/paint-hitches.ndjson |
| paint | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/paint.json |
| navigate | I1 | frame-time | p95 frame time gallery 8.87 ms over 74 frames, reveal 19.05 ms over 173 frames (all windows 19.05 ms) over 247 frames | <= 16.7 ms | fail | integration/samples/navigate-samples.ndjson |
| navigate | I2 | hitch-bound | longest frame 46.44 ms over 247 frames | <= 100 ms | pass | integration/samples/navigate-hitches.ndjson |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 795.4 ms | <= 500 ms | fail | integration/logs/harness-1793962949-navigate.log |
| navigate | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/navigate.json |
| ui-ack | I8 | response-delay | longest acknowledgement among ack:back, ack:open, ack:settings: 29.0 ms | <= 500 ms | pass | integration/logs/harness-1793962913-ui-ack.log |
| ui-ack | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/ui-ack.json |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/solve-reset.json |
| kill-relaunch | I10 | resume-after-failure | launch entry: gallery stand-in (shell home); reopened: true; marks restored: true; elapsed restored: true | Next launch is gallery; reopen restores marks and elapsed | pass | integration/logs/relaunch-verify.json |
| self-test | - | - | protocol not run in this folder | - | not run | - |

