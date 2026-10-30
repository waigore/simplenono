---
name: create-project-task
description: |-
  Create a GitHub Task issue (type:task) from docs/issues/; attach parent via
  sub-issue and wire native blocked-by dependencies.
  Use when the user asks for a concrete unit of agent work or a child of an epic/task.
  Use proactively when breaking an epic into implementable work items.

  Examples:
  - user: "Add a task under epic #3 for the movement controller" → create, sub-issue under #3
  - user: "Task for HUD, blocked by #10, parent #3" → create + parent + blocked-by
  - user: "Draft task only, don't file it" → --no-create
---

# Create project task (facade)

Canonical instructions: [`.agents/skills/create-project-task/SKILL.md`](../../../.agents/skills/create-project-task/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
