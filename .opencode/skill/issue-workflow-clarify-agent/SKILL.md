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

# Issue workflow clarify agent (facade)

Canonical instructions: [`.agents/skills/issue-workflow-clarify-agent/SKILL.md`](../../../.agents/skills/issue-workflow-clarify-agent/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.

