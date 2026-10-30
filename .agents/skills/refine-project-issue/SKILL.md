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

# Refine project issue

Veneer over the [action shell](../enforce-task-workflow-status/references/action-shell.md) for `status:pending-refinement`.

Load the latest fail or review feedback. Edit the issue body, not only a comment, so required sections stay valid per `docs/issues/`. Comment summarizing what changed. Gate: `pending-refinement` → `pending-review`.

## Rules

- Refinements belong in the body.
- Keep body shapes from `docs/issues/body-shapes.md`.
- Strip or rewrite acceptance criteria that require story-row `none` cells to name a live `type:defect`. Align with [`requirements.md`](../../../docs/issues/requirements.md) and [`story-rows.md`](../../../specs/playtest/story-rows.md).
