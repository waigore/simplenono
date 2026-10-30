---
name: redefine-project-issue
description: |-
  Replace a task/defect in status:pending-redefinition with a new task that
  states the unresolved problem succinctly, labeled pending-clarification;
  remap parent/blocked-by, comment supersession, close the old issue as
  not_planned. Called by project-planner-agent after the comment-cap lock.
  Keep this skill thin; linking follows create-project-task.

  Examples:
    - planner finds #42 pending-redefinition → new task, close #42
    - user: "Redefine the locked defect #17" → same flow (always a new task)
---

# Redefine project issue (facade)

Canonical instructions: [`.agents/skills/redefine-project-issue/SKILL.md`](../../../.agents/skills/redefine-project-issue/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
