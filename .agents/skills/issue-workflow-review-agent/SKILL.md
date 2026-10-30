---
name: issue-workflow-review-agent
description: |-
  Background dispatch for status:pending-review: resolve or discover one typed
  issue, then run review-project-issue (comments + status gate). Use when
  automation dispatches an unattended review agent.

  Examples:
    - dispatch with no issue → discover pending-review, pick one, review
    - dispatch with #12 → review-project-issue on #12
---

# Issue workflow review agent

Veneer for unattended `status:pending-review`.

Resolve one issue per [`docs/issues/workflow-dispatch.md`](../../../docs/issues/workflow-dispatch.md), then read and run [`review-project-issue`](../review-project-issue/SKILL.md). Report that skill's outcome. Do not restate discovery or transitions.
