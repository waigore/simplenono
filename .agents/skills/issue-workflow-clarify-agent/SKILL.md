---
name: issue-workflow-clarify-agent
description: |-
  Background dispatch for status:pending-clarification: resolve or discover one
  typed issue, then run clarify-project-issue when PO answers are available.
  Use when automation dispatches an unattended clarify agent.

  Examples:
    - dispatch with PO answer for #5 → clarify-project-issue on #5
    - dispatch with no PO answer → stop and report; do not invent clarification
---

# Issue workflow clarify agent

Veneer for unattended `status:pending-clarification`.

Resolve one issue per [`docs/issues/workflow-dispatch.md`](../../../docs/issues/workflow-dispatch.md). Skip candidates that need product-owner input you do not have. If no clarification is in the dispatch context, stop and report. Do not invent answers. Otherwise read and run [`clarify-project-issue`](../clarify-project-issue/SKILL.md) and report that skill's outcome.
