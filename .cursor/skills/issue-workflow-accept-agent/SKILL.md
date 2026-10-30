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

# Issue workflow accept agent (facade)

Canonical instructions: [`.agents/skills/issue-workflow-accept-agent/SKILL.md`](../../../.agents/skills/issue-workflow-accept-agent/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.

