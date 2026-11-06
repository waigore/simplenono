# Integration harness run

- **Run folder:** `docs/quality/evidence/issue-693/2026-11-06-verify-2`
- **Generated:** 1793956763
- **Protocols run:** app-start, kill-relaunch, navigate, paint, solve-reset, ui-ack
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | cold launch to the interactive shell home (menu): 2567.1 ms | <= 3 s | pass | integration/logs/harness-1793956708-app-start.log |
| paint | I1 | frame-time | p95 frame time 22.73 ms over 203 frames | <= 16.7 ms | fail | integration/samples/paint-samples.ndjson |
| paint | I2 | hitch-bound | longest frame 36.00 ms over 203 frames | <= 100 ms | pass | integration/samples/paint-hitches.ndjson |
| paint | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/paint.json |
| navigate | I1 | frame-time | p95 frame time gallery 8.33 ms over 70 frames, reveal 21.28 ms over 173 frames (all windows 18.06 ms) over 243 frames | <= 16.7 ms | fail | integration/samples/navigate-samples.ndjson |
| navigate | I2 | hitch-bound | longest frame 39.27 ms over 243 frames | <= 100 ms | pass | integration/samples/navigate-hitches.ndjson |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 766.5 ms | <= 500 ms | fail | integration/logs/harness-1793956718-navigate.log |
| navigate | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/navigate.json |
| ui-ack | I8 | response-delay | longest acknowledgement among ack:back, ack:open, ack:settings: 31.6 ms | <= 500 ms | pass | integration/logs/harness-1793956724-ui-ack.log |
| ui-ack | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/ui-ack.json |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/solve-reset.json |
| kill-relaunch | I10 | resume-after-failure | the mark phase never held | Next launch is gallery; reopen restores marks and elapsed | fail | integration/logs/relaunch-verify.json |
| self-test | - | - | protocol not run in this folder | - | not run | - |

