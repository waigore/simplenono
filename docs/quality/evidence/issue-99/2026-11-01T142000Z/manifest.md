# Quality evaluator run — issue #99

- **Issue:** #99 Godot project skeleton & repo layout
- **Mode:** `deterministic`
- **Deliverable commit:** `97b1042d9adde9f7762a626b6c7b27e58350851f` (PR #115, merged)
- **Runner:** `issue-workflow-verify-agent` (parallel id 1), 2026-11-01

## Results

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence |
|------|-----------|-------------|-----|--------|----------------|----------|
| `crash-free` | deterministic | No flow exists yet: the deliverable adds a skeleton (`game/project.godot`, `game/main.tscn` = one bare `Node`) and three empty module dirs; open / solve / reset / back are all #101 or later (CMP-shell). Invariant I9 (integration) cannot be driven against this deliverable. | No crash across open, solve, reset, and back flows | blocked | `no-invariant` — I9's flows do not exist in this deliverable, so the observation it describes cannot be taken | `game/main.tscn`, `docs/issues/body-shapes.md` scope of #99 |
| `resume-after-failure` | deterministic | Same: no attempt, no progress, no persistence in this deliverable (M2/M3 are empty `.gitkeep` dirs). Invariant I10 (kill-and-relaunch harness) cannot be driven. | After kill/crash mid-puzzle, next launch is gallery; marks and elapsed restore on reopen | blocked | `no-invariant` — I10's flows do not exist in this deliverable | `game/play/.gitkeep`, `game/records/.gitkeep` |

Other Applies axes (`frame-time`, `hitch-bound`, `time-to-playable`, `transition-latency`, `response-delay`, `runtime-signals`, `save-survives`, `failed-write`) were not selected: none of their outcomes can move for a skeleton with no screens, timing, telemetry, or persistence.

## Coverage / cross-reference

- No cataloged assets are added or changed by #99 — `game/assets/` is untouched by PR #115.
- `review-asset` not applicable.

## Verdict

`Fail` — two Applies deterministic axes evaluated as blocked (`no-invariant`). Per
[`run-quality-evaluators`](../../../../../.agents/skills/run-quality-evaluators/SKILL.md), a blocked row fails the run.
