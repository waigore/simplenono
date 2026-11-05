# Integration harness run

- **Run folder:** `/home/waigore/simplenono/1/.orc/worktrees/issue-workflow-verify-agent-1-20261105T082701608118Z/docs/quality/evidence/issue-623/2026-11-05-verify`
- **Generated:** 1793868451
- **Protocols run:** app-start, kill-relaunch, navigate, paint, solve-reset, ui-ack
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | cold launch to the interactive shell home (menu): 1786.5 ms | <= 3 s | pass | integration/logs/harness-1793867918-app-start.log |
| paint | I1 | frame-time | p95 frame time 16.67 ms over 203 frames | <= 16.7 ms | pass | integration/samples/paint-samples.ndjson |
| paint | I2 | hitch-bound | longest frame 24.57 ms over 203 frames | <= 100 ms | pass | integration/samples/paint-hitches.ndjson |
| paint | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/paint.json |
| navigate | I1 | frame-time | p95 frame time gallery 9.25 ms over 71 frames, reveal 15.00 ms over 172 frames (all windows 14.87 ms) over 243 frames | <= 16.7 ms | pass | integration/samples/navigate-samples.ndjson |
| navigate | I2 | hitch-bound | longest frame 33.35 ms over 243 frames | <= 100 ms | pass | integration/samples/navigate-hitches.ndjson |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 562.3 ms | <= 500 ms | fail | integration/logs/harness-1793867987-navigate.log |
| navigate | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/navigate.json |
| ui-ack | I8 | response-delay | longest acknowledgement among ack:back, ack:open, ack:settings: 24.6 ms | <= 500 ms | pass | integration/logs/harness-1793867936-ui-ack.log |
| ui-ack | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/ui-ack.json |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/solve-reset.json |
| kill-relaunch | I10 | resume-after-failure | launch entry: gallery stand-in (shell home); reopened: true; marks restored: true; elapsed restored: true | Next launch is gallery; reopen restores marks and elapsed | pass | integration/logs/relaunch-verify.json |
| self-test | - | - | protocol not run in this folder | - | not run | - |

