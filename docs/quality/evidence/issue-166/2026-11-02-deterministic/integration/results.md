# Integration harness run

- **Run folder:** `/private/var/folders/nj/j957smtj3jz0fn193bb2g_2c0000gn/T/opencode/verify-166/docs/quality/evidence/issue-166/2026-11-02-deterministic`
- **Generated:** 1793557878
- **Protocols run:** app-start, kill-relaunch, navigate, paint, solve-reset, ui-ack
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | cold launch to the interactive shell home (gallery stand-in until #94): 190.4 ms | <= 3 s | pass | integration/logs/harness-1793557873-app-start.log |
| app-start | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/app-start.json |
| paint | I1 | frame-time | p95 frame time 6.94 ms over 103 frames | <= 16.7 ms | pass | integration/samples/paint-samples.ndjson |
| paint | I2 | hitch-bound | longest frame 7.63 ms over 103 frames | <= 100 ms | pass | integration/samples/paint-hitches.ndjson |
| paint | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/paint.json |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 285.4 ms; protocol failed: result-shown: view is puzzle, expected result | <= 500 ms | fail | integration/logs/harness-1793557874-navigate.log |
| navigate | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/navigate.json |
| ui-ack | I8 | response-delay | longest acknowledgement among ack:back, ack:open, ack:settings: 1.3 ms | <= 500 ms | pass | integration/logs/harness-1793557875-ui-ack.log |
| ui-ack | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/ui-ack.json |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/solve-reset.json |
| kill-relaunch | I10 | resume-after-failure | launch entry: gallery stand-in (shell home); reopened: true; marks restored: false; elapsed restored: false | Next launch is gallery; reopen restores marks and elapsed | fail | integration/logs/relaunch-verify.json |
| self-test | - | - | protocol not run in this folder | - | not run | - |

