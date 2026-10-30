---
name: enforce-task-workflow-status
description: |-
  Gate or audit epic/task/defect status:* labels per docs/issues/workflow.md,
  and repair duplicate priority:* labels (keep highest).
  Use when transitioning workflow status after review/refine/clarify/implement/verify/accept,
  or when auditing issues for missing or duplicate status/priority labels.
  Use proactively before applying a status change so only one valid status:* remains.

  Examples:
    - user: "Move #12 to pending-verification" → gate: assert from, swap label
    - user: "Audit open issues for status labels" → standalone repair/report
    - called by review-project-issue after a pass comment → gate pending-review → pending-implementation
---

# Enforce task workflow status (facade)

Canonical instructions: [`.agents/skills/enforce-task-workflow-status/SKILL.md`](../../../.agents/skills/enforce-task-workflow-status/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
