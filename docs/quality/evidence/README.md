# Quality evaluator evidence

In-repo results from [`run-quality-evaluators`](../../../.agents/skills/run-quality-evaluators/SKILL.md). Axes and bars: [`specs/definition/quality.md`](../../../specs/definition/quality.md) and [`specs/definition/quality/rubrics.md`](../../../specs/definition/quality/rubrics.md).

## Layout

`issue-<n>/<run-id>/manifest.md` records the issue, the mode (`deterministic` or `llm-judge`), the deliverable commit, and one results table.

Each results row is one axis: axis id, evaluator, observation or level, bar, pass / fail / blocked, a blocked reason when blocked, and the path to the observation. There is no combined score.

## Integration harness

A quality run whose axes are observed by the [integration harness](../../../game/test/integration/README.md) also holds `integration/` beside the evaluator's `manifest.md`:

| Path | Content |
|------|---------|
| `integration/results.md` | One row per protocol × invariant: protocol, invariant, axis, observation, bar, pass / fail, artifact path |
| `integration/samples/` | Per-frame and hitch NDJSON sampled during grid paint |
| `integration/logs/` | The S4 telemetry log keyed to the harness session / build id, and S5 state dumps |
| `integration/results/` | The raw per-protocol result JSON the summary is generated from |

The harness never writes `manifest.md`: that stays the evaluator's record of the issue, mode, and deliverable commit. `run-quality-evaluators` cites `integration/results.md` for the observation path of each axis.

Each raw result also carries `flows`: [`flows.solve`](../../../game/test/integration/solve_oracle.gd) is the solved-state oracle's reading — `solved_grid` is `pass`, `absent`, `mismatch`, or `refused`, and `solution_fills` is `match` or the cells left unfilled. It is a citation of the harness's own record, not a new invariant row. A lane time in `I6`–`I8` is an observation only when its leg completed (`specs/technical/verification.md` H5); a failed leg is reported as not completed with no millisecond figure.

## When a folder is written

A run writes a folder only when it selects at least one Applies axis. A run that selects nothing writes nothing. Markdown under `issue-*` is outside the 500-word cap. This README stays inside it.

## Reuse

A passing `deterministic` record stays valid for that issue while `game/` at the deliverable commit matches `game/` at the recorded commit (`git diff <recorded> <deliverable> -- game/` is empty). Other paths may differ. A **fail** or **blocked** row still applies.

Verification writes a new `deterministic` record only when no passing record covers that `game/` tree. Land it on the open fix PR. After that PR has merged, an evidence-only chore PR is allowed only when nothing reusable exists.

Acceptance cites the matching passing record and does not re-run `deterministic`. It cites the latest `llm-judge` run for qualitative axes.
