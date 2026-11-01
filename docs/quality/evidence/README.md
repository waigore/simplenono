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

## When a folder is written

A run writes a folder only when it selects at least one Applies axis. A run that selects nothing writes nothing.

## Who writes a record

| Mode | Who may write it | Who may cite it |
|------|------------------|-----------------|
| `deterministic` | `verify-project-issue` (the only legal producer), or a user-directed `run-quality-evaluators` run | Verification, and acceptance |
| `llm-judge` | `accept-project-issue`, or a user-directed run | Acceptance |

A `manifest.md` names its issue, mode, and deliverable commit. Whoever writes it does not change the rubric, the target, or the mode.

## Who cites it

Verification cites the latest `deterministic` run for that issue and deliverable commit, and cannot Pass without it when an Applies deterministic axis can move. Acceptance cites that same run for deterministic axes and cites the latest `llm-judge` run for qualitative axes.

Acceptance cites a deterministic record it did not produce. Citing means linking the path and its deliverable commit in the acceptance comment. Acceptance does not edit, re-run, or re-mode that record. If none covers the deliverable commit, acceptance comments and gates back to `pending-verification` ([`workflow-deterministic-record.md`](../../issues/workflow-deterministic-record.md)) instead of waiting on `pending-acceptance`.
