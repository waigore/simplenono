---
name: create-project-epic
description: |-
  Create a GitHub Epic issue (type:epic) from docs/issues/, then wire native
  blocked-by dependencies when provided.
  Use when the user asks for an epic, a broad orchestration outcome, or a parent for multiple tasks.
  Use proactively when planning work that should be split into linked tasks.

  Examples:
  - user: "Create an epic for player movement" → collect per docs/issues/, create, report URL
  - user: "Draft an epic body only" → --no-create, print markdown body
  - user: "Epic for audio, blocked by #4" → create + native blocked-by
---

# Create project epic

Veneer for a repository **Epic** (`type:epic`).

**Create:** read and apply [`typed-issue-create.md`](../create-project-task/references/typed-issue-create.md).

## Deltas

- Collect optional notes, `blocked_by`, and `blocking`.
- Do not create child tasks unless asked. Use `create-project-task` for children.

## Related

- Form: `.github/ISSUE_TEMPLATE/epic.yml`
- Contract: `docs/issues/`
- Workflow: `docs/issues/workflow.md`
