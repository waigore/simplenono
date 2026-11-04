# Integration harness run

- **Run folder:** `/private/var/folders/nj/j957smtj3jz0fn193bb2g_2c0000gn/T/opencode/simplenono-550/docs/quality/evidence/issue-550/2026-11-05-verify`
- **Generated:** 1793809679
- **Protocols run:** app-start, kill-relaunch, navigate, paint, solve-reset, ui-ack
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | cold launch to the interactive shell home (gallery): 271.3 ms | <= 3 s | pass | integration/logs/harness-1793809670-app-start.log |
| paint | I1 | frame-time | p95 frame time 6.94 ms over 203 frames | <= 16.7 ms | pass | integration/samples/paint-samples.ndjson |
| paint | I2 | hitch-bound | longest frame 7.62 ms over 203 frames | <= 100 ms | pass | integration/samples/paint-hitches.ndjson |
| paint | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/paint.json |
| navigate | I1 | frame-time | p95 frame time gallery 6.98 ms over 76 frames, reveal 6.94 ms over 161 frames (all windows 6.94 ms) over 237 frames | <= 16.7 ms | pass | integration/samples/navigate-samples.ndjson |
| navigate | I2 | hitch-bound | longest frame 10.62 ms over 237 frames | <= 100 ms | pass | integration/samples/navigate-hitches.ndjson |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 215.3 ms | <= 500 ms | pass | integration/logs/harness-1793809674-navigate.log |
| navigate | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/navigate.json |
| ui-ack | I8 | response-delay | longest acknowledgement among ack:back, ack:open, ack:settings: 7.4 ms | <= 500 ms | pass | integration/logs/harness-1793809673-ui-ack.log |
| ui-ack | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/ui-ack.json |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/solve-reset.json |
| kill-relaunch | I10 | resume-after-failure | launch entry: gallery stand-in (shell home); reopened: true; marks restored: true; elapsed restored: false | Next launch is gallery; reopen restores marks and elapsed | fail | integration/logs/relaunch-verify.json |
| self-test | - | - | protocol not run in this folder | - | not run | - |

