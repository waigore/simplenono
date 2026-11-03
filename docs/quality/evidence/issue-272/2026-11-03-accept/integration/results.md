# Integration harness run

- **Run folder:** `/home/waigore/simplenono/1/docs/quality/evidence/issue-272/2026-11-03-accept`
- **Generated:** 1793706214
- **Protocols run:** app-start
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | cold launch to the interactive shell home (gallery): 1900.4 ms | <= 3 s | pass | integration/logs/harness-1793706213-app-start.log |
| paint | I1 | frame-time | protocol not run in this folder | <= 16.7 ms | not run | - |
| paint | I2 | hitch-bound | protocol not run in this folder | <= 100 ms | not run | - |
| paint | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| navigate | I1 | frame-time | protocol not run in this folder | <= 16.7 ms | not run | - |
| navigate | I2 | hitch-bound | protocol not run in this folder | <= 100 ms | not run | - |
| navigate | I7 | transition-latency | protocol not run in this folder | <= 500 ms | not run | - |
| navigate | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| ui-ack | I8 | response-delay | protocol not run in this folder | <= 500 ms | not run | - |
| ui-ack | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| solve-reset | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| kill-relaunch | I10 | resume-after-failure | protocol not run in this folder | Next launch is gallery; reopen restores marks and elapsed | not run | - |
| self-test | - | - | protocol not run in this folder | - | not run | - |

