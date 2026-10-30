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

# Run quality evaluators (facade)

Canonical instructions: [`.agents/skills/run-quality-evaluators/SKILL.md`](../../../.agents/skills/run-quality-evaluators/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
