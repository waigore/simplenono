# Integration harness run

- **Run folder:** `docs/quality/evidence/issue-277/2026-11-03-verify`
- **Generated:** 1793708224
- **Protocols run:** app-start
- **Manifest:** not written by the harness; `run-quality-evaluators` owns `manifest.md`.

## Results

| Protocol | Invariant | Axis | Observation | Bar | Result | Artifact |
|----------|-----------|------|-------------|-----|--------|----------|
| app-start | I6 | time-to-playable | cold launch to the interactive shell home (gallery): 2089.6 ms; 0 rejected pack rows; `flows_failed` empty | <= 3 s | pass | harness session `harness-1793708223` (log not kept in git; reproduce below) |
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

## Reproduce

Run at the deliverable commit, from a clean worktree:

```sh
godot --headless --path game --import   # once, to build the class cache
godot --headless --path game -s test/integration/run_protocol.gd -- \
    --debug-seams --protocol=app-start --run-dir=<scratch folder>
```

Exit `0` and `HARNESS protocol=app-start outcome=pass`; the observation is the `launch-start` -> `launch-stop`
interval the harness prints into its session log. The harness writes `logs/`, `samples/`, and `results/` into the
run folder; those are gitignored under `docs/quality/evidence/`, so only this `results.md` and `manifest.md` are
kept in git.
