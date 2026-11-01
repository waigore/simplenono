---
name: create-project-epic
description: |-
  Create a GitHub Epic issue (type:epic) from docs/issues/. Blocked-by is
  banned (hierarchy.md).
  Use when the user asks for an epic, a broad orchestration outcome, or a parent for multiple tasks.
  Use proactively when planning work that should be split into linked tasks.

  Examples:
  - user: "Create an epic for player movement" → collect per docs/issues/, create, report URL
  - user: "Draft an epic body only" → --no-create, print markdown body
  - user: "Epic for audio" → create without blocked-by
---

# Create project epic (facade)

Canonical instructions: [`.agents/skills/create-project-epic/SKILL.md`](../../../.agents/skills/create-project-epic/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
