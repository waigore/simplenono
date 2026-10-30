---
name: issue-workflow-implement-agent
description: |-
  Background dispatch for status:pending-implementation: resolve or discover one
  typed issue, perform the implementation work, then run implement-project-issue
  (deliverables comment + status gate). Product behavior with no formalized spec
  stops for capture-requirements. A PoC starts only when the issue asks to
  explore. Use when automation dispatches an unattended implement agent.

  Examples:
    - dispatch with no issue → discover pending-implementation, pick one, implement
    - dispatch with #12 → implement #12, then implement-project-issue
---

# Issue workflow implement agent (facade)

Canonical instructions: [`.agents/skills/issue-workflow-implement-agent/SKILL.md`](../../../.agents/skills/issue-workflow-implement-agent/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.

