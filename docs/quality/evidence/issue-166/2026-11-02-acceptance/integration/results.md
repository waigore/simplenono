# Integration harness run

- **Run folder:** `docs/quality/evidence/issue-166/2026-11-02-acceptance` (headless acceptance re-run on `main` `66c6363`)
- **Generated:** 1793561164
- **Protocols run:** app-start, kill-relaunch, navigate, paint, self-test, solve-reset, ui-ack
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | cold launch to the interactive shell home (gallery stand-in until #94): 185.6 ms | <= 3 s | pass | integration/logs/harness-1793561156-app-start.log |
| paint | I1 | frame-time | p95 frame time 6.94 ms over 203 frames | <= 16.7 ms | pass | integration/samples/paint-samples.ndjson |
| paint | I2 | hitch-bound | longest frame 7.91 ms over 203 frames | <= 100 ms | pass | integration/samples/paint-hitches.ndjson |
| paint | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/paint.json |
| navigate | I7 | transition-latency | longest transition among transition:home-puzzle, transition:puzzle-result, transition:result-gallery: 2289.6 ms (driver-timed, not a product observation: transition:result-gallery: the shell's leave sets its own view; #94/#95 own the transition); protocol failed: puzzle-result: transition:puzzle-result was not acknowledged within 2000 ms | <= 500 ms | fail | integration/logs/harness-1793561159-navigate.log |
| navigate | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/navigate.json |
| ui-ack | I8 | response-delay | longest acknowledgement among ack:back, ack:open, ack:settings: 7.8 ms | <= 500 ms | pass | integration/logs/harness-1793561162-ui-ack.log |
| ui-ack | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/ui-ack.json |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/solve-reset.json |
| kill-relaunch | I10 | resume-after-failure | launch entry: gallery stand-in (shell home); reopened: true; marks restored: false; elapsed restored: false | Next launch is gallery; reopen restores marks and elapsed | fail | integration/logs/relaunch-verify.json |
| self-test | - | - (self-test) | pass | - | pass | integration/results/self-test.json |

