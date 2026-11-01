---
name: unblock-project-issues
description: |-
  Critically examine leftover native blocked-by edges and delete those not
  justified under the hierarchy ban (preferred sequence, soft order, and
  relatedness are never justified). Does not add dependencies or close issues.
  Use when unblocking issues or at the start of a project-planner-agent pass.

  Examples:
    - user: "Unblock issues whose blockers are done" → examine every open edge
    - user: "Can #40 proceed?" → examine #40's blockers only
    - called by project-planner-agent at the start of a pass
---

# Unblock project issues (facade)

Canonical instructions: [`.agents/skills/unblock-project-issues/SKILL.md`](../../../.agents/skills/unblock-project-issues/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
