---
name: accept-project-issue
description: |-
  Accept, fail, or escalate clarification for an epic/task/defect in
  status:pending-acceptance using test evidence against acceptance criteria.
  Cite the deterministic rubric record. When an Applies llm-judge axis can
  move, run run-quality-evaluators.
  Use when running acceptance testing after verification.

  Examples:
    - user: "Accept #12 with evidence in docs/playtest/evidence/..." → accept comment, status:accepted, leave open (planner may close later)
    - user: "Acceptance failed; file defect" → create defect (game/interface only), link, → pending-implementation
    - user: "Need PO input to finish acceptance on #12" → pending-clarification
    - user: "Headless accept on #12; screenshots still waiting" → stay pending-acceptance, no defect
---

# Accept project issue (facade)

Canonical instructions: [`.agents/skills/accept-project-issue/SKILL.md`](../../../.agents/skills/accept-project-issue/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
