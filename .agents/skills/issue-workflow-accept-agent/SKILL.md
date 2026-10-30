---
name: issue-workflow-accept-agent
description: |-
  Background dispatch for status:pending-acceptance: resolve or discover one
  typed issue, then run accept-project-issue (acceptance evidence, comments +
  status gate). Use when automation dispatches an unattended accept agent.

  Examples:
    - dispatch with no issue → discover pending-acceptance, pick one, accept
    - dispatch with #12 → accept-project-issue on #12
---

# Issue workflow accept agent

Veneer for unattended `status:pending-acceptance`.

Resolve one issue per [`docs/issues/workflow-dispatch.md`](../../../docs/issues/workflow-dispatch.md), then read and run [`accept-project-issue`](../accept-project-issue/SKILL.md). Report that skill's outcome. Do not restate discovery or transitions.
