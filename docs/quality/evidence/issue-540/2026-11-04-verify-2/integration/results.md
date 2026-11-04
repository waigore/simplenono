# Integration harness run

- **Run folder:** `/Users/waigore/Documents/GitHub/simplenono/docs/quality/evidence/issue-540/2026-11-04-verify-2`
- **Generated:** 1793800233
- **Protocols run:** navigate, paint, solve-reset, ui-ack
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | protocol not run in this folder | <= 3 s | not run | - |
| paint | I1 | frame-time | p95 frame time 6.94 ms over 203 frames | <= 16.7 ms | pass | integration/samples/paint-samples.ndjson |
| paint | I2 | hitch-bound | longest frame 7.19 ms over 203 frames | <= 100 ms | pass | integration/samples/paint-hitches.ndjson |
| paint | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/paint.json |
| navigate | I1 | frame-time | p95 frame time gallery 6.94 ms over 77 frames, reveal 6.94 ms over 162 frames (all windows 6.94 ms) over 239 frames | <= 16.7 ms | pass | integration/samples/navigate-samples.ndjson |
| navigate | I2 | hitch-bound | longest frame 7.46 ms over 239 frames | <= 100 ms | pass | integration/samples/navigate-hitches.ndjson |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 208.5 ms | <= 500 ms | pass | integration/logs/harness-1793800227-navigate.log |
| navigate | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/navigate.json |
| ui-ack | I8 | response-delay | longest acknowledgement among ack:back, ack:open, ack:settings: 7.8 ms | <= 500 ms | pass | integration/logs/harness-1793800229-ui-ack.log |
| ui-ack | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/ui-ack.json |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/solve-reset.json |
| kill-relaunch | I10 | resume-after-failure | protocol not run in this folder | Next launch is gallery; reopen restores marks and elapsed | not run | - |
| self-test | - | - | protocol not run in this folder | - | not run | - |

