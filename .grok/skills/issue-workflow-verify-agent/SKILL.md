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

# Issue workflow verify agent (facade)

Canonical instructions: [`.agents/skills/issue-workflow-verify-agent/SKILL.md`](../../../.agents/skills/issue-workflow-verify-agent/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.

