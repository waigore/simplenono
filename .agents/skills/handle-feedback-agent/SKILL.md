---
name: handle-feedback-agent
description: |-
  Advance one type:feedback issue in pending-resolution to resolved when
  related work is done. No disposition, filing, or clarification.
  Use when automation dispatches handle-feedback-agent, or a feedback issue
  needs that pass.

  Examples:
    - Assigned issue: 12 → track #12
    - Assigned issue: none → one pending-resolution feedback issue
---

# Handle feedback agent

Veneer for one feedback issue in `status:pending-resolution`. Contract: [`docs/issues/feedback.md`](../../../docs/issues/feedback.md). Discovery: [`docs/issues/workflow-dispatch.md`](../../../docs/issues/workflow-dispatch.md).

One issue, then stop. Do not dispose points, file issues, clarify, edit the repo, or close the feedback issue. When every related issue is `status:accepted` or closed, gate `pending-resolution` → `resolved` with `enforce-task-workflow-status` and comment the evidence. If related work is still open, comment that and leave the status unchanged.
