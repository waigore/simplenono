# Integration harness run

- **Run folder:** `/tmp/opencode/verify-310/docs/quality/evidence/issue-310/2026-11-02-verify`
- **Generated:** 1793606212
- **Protocols run:** paint, solve-reset
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | protocol not run in this folder | <= 3 s | not run | - |
| paint | I1 | frame-time | p95 frame time 16.55 ms over 203 frames | <= 16.7 ms | pass | integration/samples/paint-samples.ndjson |
| paint | I2 | hitch-bound | longest frame 27.18 ms over 203 frames | <= 100 ms | pass | integration/samples/paint-hitches.ndjson |
| paint | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/paint.json |
| navigate | I1 | frame-time | protocol not run in this folder | <= 16.7 ms | not run | - |
| navigate | I2 | hitch-bound | protocol not run in this folder | <= 100 ms | not run | - |
| navigate | I7 | transition-latency | protocol not run in this folder | <= 500 ms | not run | - |
| navigate | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| ui-ack | I8 | response-delay | protocol not run in this folder | <= 500 ms | not run | - |
| ui-ack | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/solve-reset.json |
| kill-relaunch | I10 | resume-after-failure | protocol not run in this folder | Next launch is gallery; reopen restores marks and elapsed | not run | - |
| self-test | - | - | protocol not run in this folder | - | not run | - |

