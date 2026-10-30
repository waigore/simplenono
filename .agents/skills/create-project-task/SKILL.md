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

# Create project task

Veneer for a repository **Task** (`type:task`).

**Create:** read and apply [`references/typed-issue-create.md`](references/typed-issue-create.md).

## Deltas

- Collect optional `parent`, `blocked_by`, and `blocking`.
- **Before create:** if the unit mixes main-tree UI with non-UI work, prefer two tasks ([`docs/ux-mockups.md`](../../../docs/ux-mockups.md)). If `parent` is set, validate depth per `hierarchy.md` and the linking reference. Abort when the new task would exceed 3 levels from epic to leaf.
- Do not invent a parent. Attach one only when the user names it.
- Draft acceptance criteria per [`requirements.md`](../../../docs/issues/requirements.md). If the task touches [`specs/playtest/story-rows.md`](../../../specs/playtest/story-rows.md), require epic or task owners or durable `none` reasons. Never require every `none` to name a live `type:defect`.

## Related

- Form: `.github/ISSUE_TEMPLATE/task.yml`
- Contract: `docs/issues/`
- Workflow: `docs/issues/workflow.md`
- Parent skill: `create-project-epic`
