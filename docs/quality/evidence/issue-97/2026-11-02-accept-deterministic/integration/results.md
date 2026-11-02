# Integration harness run

- **Run folder:** `/home/waigore/simplenono/1/docs/quality/evidence/issue-97/2026-11-02-accept-deterministic`
- **Generated:** 1793592723
- **Protocols run:** app-start, navigate, paint, solve-reset, ui-ack
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | cold launch to the interactive shell home (gallery): 1708.6 ms | <= 3 s | pass | integration/logs/harness-1793592708-app-start.log |
| paint | I1 | frame-time | p95 frame time 8.33 ms over 203 frames | <= 16.7 ms | pass | integration/samples/paint-samples.ndjson |
| paint | I2 | hitch-bound | longest frame 11.69 ms over 203 frames | <= 100 ms | pass | integration/samples/paint-hitches.ndjson |
| paint | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/paint.json |
| navigate | I1 | frame-time | p95 frame time gallery 8.33 ms over 73 frames, reveal 6.94 ms over 162 frames (all windows 7.58 ms) over 235 frames | <= 16.7 ms | pass | integration/samples/navigate-samples.ndjson |
| navigate | I2 | hitch-bound | longest frame 20.09 ms over 235 frames | <= 100 ms | pass | integration/samples/navigate-hitches.ndjson |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 214.1 ms | <= 500 ms | pass | integration/logs/harness-1793592714-navigate.log |
| navigate | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/navigate.json |
| ui-ack | I8 | response-delay | longest acknowledgement among ack:back, ack:open, ack:settings: 27.9 ms | <= 500 ms | pass | integration/logs/harness-1793592717-ui-ack.log |
| ui-ack | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/ui-ack.json |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/solve-reset.json |
| kill-relaunch | I10 | resume-after-failure | protocol not run in this folder | Next launch is gallery; reopen restores marks and elapsed | not run | - |
| self-test | - | - | protocol not run in this folder | - | not run | - |

