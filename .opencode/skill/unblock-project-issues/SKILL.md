---
name: unblock-project-issues
description: |-
  Clear a native blocked-by link when the default branch already satisfies the
  blocker's done-conditions, or when the edge is obsolete / never warranted.
  Acceptance and closed state do not gate clearance. Use when unblocking
  issues, checking whether a block still holds, or at the start of a
  project-planner-agent pass. Does not add dependencies or close issues.

  Examples:
    - user: "Unblock issues whose blockers are done" → judge every open edge against the default branch
    - user: "Can #40 proceed?" → judge #40's blockers only
    - called by project-planner-agent at the start of a pass
---

# Unblock project issues (facade)

Canonical instructions: [`.agents/skills/unblock-project-issues/SKILL.md`](../../../.agents/skills/unblock-project-issues/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
