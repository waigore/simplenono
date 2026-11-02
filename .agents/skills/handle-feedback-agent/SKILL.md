---
name: handle-feedback-agent
description: |-
  Carry one type:feedback issue through analysis and resolution.
  Use when automation dispatches handle-feedback-agent, or a feedback issue
  needs that pass.

  Examples:
    - Assigned issue: 12 → handle #12
    - Assigned issue: none → one pending-analysis issue, else pending-resolution
---

# Handle feedback agent

Veneer for one feedback issue. Contract: [`docs/issues/feedback.md`](../../../docs/issues/feedback.md). Discovery: [`docs/issues/workflow-dispatch.md`](../../../docs/issues/workflow-dispatch.md).

Prefer `status:pending-analysis`, otherwise `status:pending-resolution`. One issue, then stop. Do not edit the repo. Do not close the feedback issue. Gate status with `enforce-task-workflow-status`. File tasks and defects with `create-project-task` and `create-project-defect`. Product-owner answers on `pending-clarification` go through `clarify-project-issue`.
