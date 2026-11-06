# Integration harness run

- **Run folder:** `/home/waigore/simplenono/1/.orc/worktrees/issue-workflow-accept-agent-1-20261106T143637739175Z/docs/playtest/evidence/issue-700/2026-11-06-accept-1`
- **Generated:** 1793976519
- **Protocols run:** self-test
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
| ui-ack | I8 | response-delay | protocol not run in this folder | <= 500 ms | not run | - |
| ui-ack | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| solve-reset | I9 | crash-free | protocol not run in this folder | No crash across open, solve, reset, and back | not run | - |
| self-test | - | - (self-test) | pass | - | pass | integration/results/self-test.json |

