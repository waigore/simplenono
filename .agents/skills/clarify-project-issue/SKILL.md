---
name: clarify-project-issue
description: |-
  Record product-owner clarification on an epic/task/defect in
  status:pending-clarification, then move to pending-review or pending-refinement.
  Use when the PO answers open questions or the user provides clarification to post.

  Examples:
    - user: "PO clarified #5: jump height is 2 tiles" → comment + gate to pending-review
    - user: "Clarification on #5 still needs a body rewrite" → comment + pending-refinement
---

# Clarify project issue

Veneer over the [action shell](../enforce-task-workflow-status/references/action-shell.md) for `status:pending-clarification` on epic, task, or defect. Feedback issues do not use this status ([`feedback.md`](../../../docs/issues/feedback.md)).

Load the outstanding clarification questions. Collect the product-owner clarification. Ask if it is missing. Do not invent answers. Comment with the clarification and attribute the product owner when known.

When the outstanding questions are in-repo approval (mockup catalog rows, aesthetics references, or style anchors), record approve/reject clearly, and for style anchors the chosen approved IDs, so the next `review-project-issue` Pass can apply catalog/registry writes. Do not write those records here unless the product owner asks to apply them in the same turn; default is comment → `pending-review`.

- Body still needs edits → gate `pending-clarification` → `pending-refinement`, then use `refine-project-issue` if refining now.
- Otherwise → gate `pending-clarification` → `pending-review`.

Do not skip review after clarification unless the user explicitly continues into the refine or review skill.
