---
name: run-quality-evaluators
description: |-
  Execute Applies quality-rubric axes for one deliverable and write one
  evidence record. deterministic mode reads or runs the citing invariant and
  compares it to the characteristic target. llm-judge mode assigns the
  recorded scale using only the judge record's evidence. Does not change
  issue status or edit rubrics.
  Use from verify-project-issue (deterministic) or accept-project-issue
  (llm-judge), or when the user asks to evaluate quality axes.

  Examples:
    - verify-project-issue: an Applies deterministic axis can move → run deterministic; a failed or blocked axis fails verify
    - accept-project-issue: an Applies llm-judge axis can move → run llm-judge
    - user: "Evaluate frame-time for #12" → deterministic mode for that axis
---

# Run quality evaluators

Execute axes. Authoring stays in [`author-quality-rubrics`](../author-quality-rubrics/SKILL.md). This skill does not change `status:*` and does not edit a rubric.

**Bars and axes:** [`specs/definition/quality.md`](../../../specs/definition/quality.md), [`specs/definition/quality/rubrics.md`](../../../specs/definition/quality/rubrics.md). Rules: [`.agents/specs/rules/quality.md`](../../specs/rules/quality.md).

**Evidence:** [`docs/quality/evidence/README.md`](../../../docs/quality/evidence/README.md).

## Mode

The caller sets one mode. Refuse axes of the other kind.

- `deterministic` — [`verify-project-issue`](../verify-project-issue/SKILL.md), or a user evaluating deterministic axes.
- `llm-judge` — [`accept-project-issue`](../accept-project-issue/SKILL.md), or a user judging qualitative axes.

## Select

Keep an axis only when it is Applies, its evaluator is the requested mode, and the deliverable can change that outcome. Main-tree deliverables only. Skip `pocs/`.

Skip N/A axes, vision qualities, playtest protocols, and per-issue acceptance criteria. When none remain, report **N/A** and stop. Do not write an evidence folder.

## deterministic

For each selected axis, use the invariant in `specs/technical/verification.md` that cites that axis id. Invariant shape: [`specs/technical/_templates/verification.md`](../../../specs/technical/_templates/verification.md).

- Read the CI or unit result when the invariant level is unit or integration. Run the smoke or benchmark when the level is smoke.
- Compare the observation to the target on the characteristic row. The row is **pass** or **fail**.
- No `verification.md`, or no citing invariant: the row is **blocked** with reason `no-invariant`.

## llm-judge

Read that axis's judge record: ordinal scale, minimum passing level, and the evidence the judge may see. The outcome text is the only criterion.

- Allowed evidence is in the repo: assign one level. **pass** when the level meets the pass level; otherwise **fail**.
- Allowed evidence is not in the repo yet: **blocked** with reason `missing-evidence`.
- The judge record omits its scale, pass level, or allowed evidence: **blocked** with reason `missing-judge-record`.

## Record

When at least one axis was selected, write `docs/quality/evidence/issue-<n>/<run-id>/` per the evidence README. One row per axis: axis id, evaluator, observation or level, bar, pass / fail / blocked, blocked reason, evidence path. No combined score.

Return that table. A **fail** or **blocked** row fails the run. Leave the rubric unchanged. A wrong rubric waits for a new `author-quality-rubrics` run.
