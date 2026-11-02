---
name: create-project-feedback
description: |-
  File a type:feedback issue in point form. No GitHub form.
  Use when the user supplies feedback to record.

  Examples:
    - user: "File this feedback: the jump feels late" → points, pending-analysis
    - user: "Draft the feedback issue only" → --no-create
---

# Create project feedback

Veneer for `type:feedback`. Contract: [`docs/issues/feedback.md`](../../../docs/issues/feedback.md).

**Create:** [`typed-issue-create.md`](../create-project-task/references/typed-issue-create.md).

## Deltas

- No parent and no blocked-by. Initial status `pending-analysis`. Priority `priority:normal`.
- Required **Points**. Split prose into points; put the raw text in **Notes**. **Analysis** and **Related issues** are `None`.
- Do not classify or file follow-up issues. That is `handle-feedback-agent`.

## Related

- Contract: `docs/issues/feedback.md`
- Body: `docs/issues/body-shapes.md`
