---
name: review-project-issue
description: |-
  Review an epic/task/defect in status:pending-review; post pass, fail, or
  clarification evidence and advance status via enforce-task-workflow-status.
  Use when the user asks to review an issue, approve it for implementation, request
  refinements, or escalate clarification to the product owner.

  Examples:
    - user: "Review #12" → holistic review, comment, gate status
    - user: "Fail review on #8; also impacts #9" → fail #8 and cascade #9 on the user's order
    - user: "Fail review on #8" → fail #8; cascade a blocked-by neighbor only with an implementation or verification deadlock
    - user: "Needs clarification on #3" → questions comment → pending-clarification
---

# Review project issue (facade)

Canonical instructions: [`.agents/skills/review-project-issue/SKILL.md`](../../../.agents/skills/review-project-issue/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
