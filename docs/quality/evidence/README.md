# Quality evaluator evidence

In-repo results from [`run-quality-evaluators`](../../../.agents/skills/run-quality-evaluators/SKILL.md). Axes and bars: [`specs/definition/quality.md`](../../../specs/definition/quality.md) and [`specs/definition/quality/rubrics.md`](../../../specs/definition/quality/rubrics.md).

## Layout

`issue-<n>/<run-id>/manifest.md` records the issue, the mode (`deterministic` or `llm-judge`), the deliverable commit, and one results table.

Each results row is one axis: axis id, evaluator, observation or level, bar, pass / fail / blocked, a blocked reason when blocked, and the path to the observation. There is no combined score.

## When a folder is written

A run writes a folder only when it selects at least one Applies axis. A run that selects nothing writes nothing.

## Who cites it

Verification cites the latest `deterministic` run for that issue and deliverable commit. Acceptance cites that same run for deterministic axes and cites the latest `llm-judge` run for qualitative axes. Acceptance does not replace the deterministic run.
