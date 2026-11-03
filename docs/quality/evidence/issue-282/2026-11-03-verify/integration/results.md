# Integration harness run — issue #282

- **Run folder:** scratch folder outside the repo (not committed; `logs/`, `samples/`, and `results/` are gitignored
  under `docs/quality/evidence/`)
- **Checkout:** detached worktree at `1b5dbc9`, clean `git status -- game/` before and after import
- **Godot:** 4.7.2.stable.official.ed1daf0bf, `--headless`
- **Generated:** 1793718363
- **Protocols run:** app-start (harness session `harness-1793718363`)
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | cold launch to the interactive shell home (gallery): 284.3 ms | <= 3 s | pass | scratch run folder, `integration/logs/harness-1793718363-app-start.log` (gitignored) |
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

Only `app-start` was run because it is the sole protocol whose axis this deliverable can reach (see
[`manifest.md`](manifest.md), Not selected). Every other row is `not run` by design, not by omission.
