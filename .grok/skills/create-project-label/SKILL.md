---
name: create-project-label
description: |-
  Add a repository label to .github/project-labels.yml and docs/labels.md, then sync it to GitHub by default.
  Use when defining a new issue label for categorization or agent orchestration.
  Use proactively when the user asks to add a label, create type:/status: labels, or extend the project label catalog.

  Examples:
  - user: "Add a type:spike label for research work" → add to config + docs, sync to GitHub
  - user: "Create a priority:high label, don't sync yet" → update files only (--no-sync)
  - user: "Register label status:blocked with color aa0000" → upsert by name, sync
  - user: "Add project label for defects we already have typed" → clarify name/description/color, then apply
---

# Create project label (facade)

Canonical instructions: [`.agents/skills/create-project-label/SKILL.md`](../../../.agents/skills/create-project-label/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
