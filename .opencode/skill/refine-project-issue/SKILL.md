---
name: refine-project-issue
description: |-
  Refine an epic/task/defect in status:pending-refinement by editing the issue
  body, posting a summary comment, and returning it to pending-review.
  Use when the user asks to apply review feedback or refine an issue body.

  Examples:
    - user: "Refine #12 per the fail review" → edit body, summary comment, gate status
    - user: "Apply refinements to the movement task" → same for that issue number
---

# Refine project issue (facade)

Canonical instructions: [`.agents/skills/refine-project-issue/SKILL.md`](../../../.agents/skills/refine-project-issue/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
