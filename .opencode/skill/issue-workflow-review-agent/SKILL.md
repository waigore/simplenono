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

# Issue workflow review agent (facade)

Canonical instructions: [`.agents/skills/issue-workflow-review-agent/SKILL.md`](../../../.agents/skills/issue-workflow-review-agent/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.

