# Quality evaluator run — issue #101

- **Issue:** #101 Shell scene stub: CMP-shell is the first screen and holds a hardcoded puzzle ID
- **Mode:** `deterministic`
- **Deliverable commit:** `ea50de505894b6ce117b7d69c69e87dea1917438` (PR #136, open, not merged)
- **Runner:** `issue-workflow-verify-agent` (parallel id 1), 2026-11-01

## Results

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence |
|------|-----------|-------------|-----|--------|----------------|----------|
| `crash-free` | deterministic | The stub is one `Control` that sets one `Label` text from a constant. Open, solve, reset, and back do not exist (AC 4 assigns them to #112/#110), so I9 (integration) has no flow to drive. A headless launch (exit 0) is smoke only and does not exercise I9. | No crash across open, solve, reset, and back flows | blocked | `no-invariant` — I9's four flows are outside this deliverable | `game/presentation/shell.gd`, `game/presentation/shell.tscn` |
| `resume-after-failure` | deterministic | No attempt, progress record, or persistence path is touched; the stub holds no marks or elapsed. I10 (kill-and-relaunch) cannot be driven. | After kill/crash mid-puzzle, next launch is gallery; marks and elapsed restore on reopen | blocked | `no-invariant` — I10 needs a mid-puzzle attempt with persisted state | diff `origin/main...origin/task/101-shell-stub` (no `game/play/`, `game/records/`) |
| `runtime-signals` | deterministic | I11 (smoke) needs severity-tagged logs, frame/hitch samples, and story-ID telemetry. `shell.gd` has no log call, no sampler, and no telemetry emit. S4's event set (open/ready/mark/solved/pause/resume/leave/commit/reset) is unreachable from a stub that opens nothing. | Severity-tagged error/crash logs, frame/hitch samples, and story-ID telemetry events are present | blocked | `no-invariant` — the S4 events I11 observes do not exist at this scope | `game/presentation/shell.gd`, `specs/technical/verification.md` S4 |

## Not selected

`frame-time` (I1), `hitch-bound` (I2), `transition-latency` (I7), `response-delay` (I8) — no paint, navigation, or non-paint action to sample. `time-to-playable` (I6) — measures cold launch to *interactive gallery*, which does not exist. `save-survives` / `failed-write` (I4) — no persistence touched. N/A accessibility and localization axes are not scored.

## Cross-reference

- No cataloged assets added or changed; `review-asset` not applicable.
- `review-code` on the PR #136 diff: **Pass**, no must-fix findings.
- Independent checks on the PR head (`ea50de5`): headless launch exit 0; GUT 96/96; all CI checks pass.
- Rationale and root cause: [`rationale.md`](rationale.md).

## Verdict

`Fail` — three Applies deterministic axes evaluated as blocked (`no-invariant`). Per
[`run-quality-evaluators`](../../../../../.agents/skills/run-quality-evaluators/SKILL.md), a blocked row fails the run, and
[`verify-project-issue`](../../../../../.agents/skills/verify-project-issue/SKILL.md) fails verification on it.
