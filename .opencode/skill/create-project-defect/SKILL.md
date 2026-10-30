---
name: create-project-defect
description: |-
  Create a GitHub Defect issue (type:defect) from docs/issues/; wire related
  links and native blocked-by when provided.
  Use when the user reports wrong game or interface behavior vs expected play.
  Do not use for specs, docs, maps, or planning gaps (tasks or clarification).

  Examples:
  - user: "File a defect: jump input ignored on web" → collect per docs/issues/, create
  - user: "Defect related to #15, blocked by #9" → related section + blocked-by
  - user: "Draft defect body only" → --no-create
---

# Create project defect (facade)

Canonical instructions: [`.agents/skills/create-project-defect/SKILL.md`](../../../.agents/skills/create-project-defect/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
