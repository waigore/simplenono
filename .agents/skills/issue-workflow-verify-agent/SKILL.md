---
name: issue-workflow-verify-agent
description: |-
  Background dispatch for status:pending-verification: resolve or discover one
  typed issue, then run verify-project-issue (independent check, comments + status
  gate). Use when automation dispatches an unattended verify agent.

  Examples:
    - dispatch with no issue → discover pending-verification, pick one, verify
    - dispatch with #12 → verify-project-issue on #12
---

# Issue workflow verify agent

Veneer for unattended `status:pending-verification`.

Resolve one issue per [`docs/issues/workflow-dispatch.md`](../../../docs/issues/workflow-dispatch.md), then read and run [`verify-project-issue`](../verify-project-issue/SKILL.md). Report that skill's outcome. Do not restate discovery or transitions.
