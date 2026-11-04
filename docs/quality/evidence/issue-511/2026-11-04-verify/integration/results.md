# Integration harness run

- **Run folder:** `/home/waigore/simplenono/1/.orc/worktrees/issue-workflow-verify-agent-1-20261104T043611988592Z/docs/quality/evidence/issue-511/2026-11-04-verify/integration`
- **Generated:** 1793767431
- **Protocols run:** solve-reset, ui-ack
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | protocol not run in this folder | <= 3 s | not run | - |
| paint | I1 | frame-time | protocol not run in this folder | <= 16.7 ms | not run | - |
| paint | I2 | hitch-bound | protocol not run in this folder | <= 100 ms | not run | - |
| paint | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| navigate | I1 | frame-time | protocol not run in this folder | <= 16.7 ms | not run | - |
| navigate | I2 | hitch-bound | protocol not run in this folder | <= 100 ms | not run | - |
| navigate | I7 | transition-latency | protocol not run in this folder | <= 500 ms | not run | - |
| navigate | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| ui-ack | I8 | response-delay | longest acknowledgement among ack:back, ack:open, ack:settings: 27.8 ms | <= 500 ms | pass | integration/logs/harness-1793767427-ui-ack.log |
| ui-ack | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/ui-ack.json |
| solve-reset | I9 | crash-free | flows ran: back, open, reset, solve | No crash across open, solve, reset, and back | pass | integration/results/solve-reset.json |
| kill-relaunch | I10 | resume-after-failure | protocol not run in this folder | Next launch is gallery; reopen restores marks and elapsed | not run | - |
| self-test | - | - | protocol not run in this folder | - | not run | - |

