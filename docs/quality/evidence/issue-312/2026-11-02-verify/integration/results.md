# Integration harness run

- **Run folder:** `/home/waigore/simplenono/1/docs/quality/evidence/issue-312/2026-11-02-verify`
- **Generated:** 1793610642
- **Protocols run:** navigate, paint, solve-reset, ui-ack
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | protocol not run in this folder | <= 3 s | not run | - |
| paint | I1 | frame-time | p95 frame time 16.67 ms over 203 frames | <= 16.7 ms | pass | integration/samples/paint-samples.ndjson |
| paint | I2 | hitch-bound | longest frame 22.09 ms over 203 frames | <= 100 ms | pass | integration/samples/paint-hitches.ndjson |
| paint | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/paint.json |
| navigate | I1 | frame-time | p95 frame time gallery 9.26 ms over 72 frames, reveal 14.58 ms over 162 frames (all windows 14.55 ms) over 234 frames | <= 16.7 ms | pass | integration/samples/navigate-samples.ndjson |
| navigate | I2 | hitch-bound | longest frame 30.03 ms over 234 frames | <= 100 ms | pass | integration/samples/navigate-hitches.ndjson |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 431.4 ms | <= 500 ms | pass | integration/logs/harness-1793610632-navigate.log |
| navigate | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/navigate.json |
| ui-ack | I8 | response-delay | longest acknowledgement among ack:back, ack:open, ack:settings: 31.4 ms | <= 500 ms | pass | integration/logs/harness-1793610637-ui-ack.log |
| ui-ack | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/ui-ack.json |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/solve-reset.json |
| kill-relaunch | I10 | resume-after-failure | protocol not run in this folder | Next launch is gallery; reopen restores marks and elapsed | not run | - |
| self-test | - | - | protocol not run in this folder | - | not run | - |

