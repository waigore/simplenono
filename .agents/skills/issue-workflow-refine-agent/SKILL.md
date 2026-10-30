---
name: issue-workflow-refine-agent
description: |-
  Background dispatch for status:pending-refinement: resolve or discover one
  typed issue, then run refine-project-issue (body edit, summary comment, status
  gate). Use when automation dispatches an unattended refine agent.

  Examples:
    - dispatch with no issue → discover pending-refinement, pick one, refine
    - dispatch with #8 → refine-project-issue on #8
---

# Issue workflow refine agent

Veneer for unattended `status:pending-refinement`.

Resolve one issue per [`docs/issues/workflow-dispatch.md`](../../../docs/issues/workflow-dispatch.md), then read and run [`refine-project-issue`](../refine-project-issue/SKILL.md). Report that skill's outcome. Do not restate discovery or transitions.
