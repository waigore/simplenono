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

# Issue workflow refine agent (facade)

Canonical instructions: [`.agents/skills/issue-workflow-refine-agent/SKILL.md`](../../../.agents/skills/issue-workflow-refine-agent/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.

