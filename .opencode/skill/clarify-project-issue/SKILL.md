---
name: clarify-project-issue
description: |-
  Record product-owner clarification on an issue in
  status:pending-clarification, then move to pending-review, pending-refinement,
  or pending-analysis for type:feedback.
  Use when the PO answers open questions or the user provides clarification to post.

  Examples:
    - user: "PO clarified #5: jump height is 2 tiles" → comment + gate to pending-review
    - user: "Clarification on #5 still needs a body rewrite" → comment + pending-refinement
---

# Clarify project issue (facade)

Canonical instructions: [`.agents/skills/clarify-project-issue/SKILL.md`](../../../.agents/skills/clarify-project-issue/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
