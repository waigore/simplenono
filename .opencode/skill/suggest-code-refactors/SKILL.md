---
name: suggest-code-refactors
description: |-
  Review implementation code for structure and technical debt and file the
  refactor epics and tasks that judgement selects. Thin orchestrator over
  audit-code-structure, create-project-epic, and create-project-task. Does not
  edit the repo. Filing needs no second confirmation.
  Use when the user asks for a structure review, refactor suggestions, or a
  technical-debt pass over the implementation tree or a named portion.

  Examples:
    - user: "Where should we refactor?" → whole tree except pocs/, file the cut
    - user: "Suggest refactors in src/combat" → that portion, file the cut
    - user: "Audit structure, don't file" → audit-code-structure only
---

# Suggest code refactors (facade)

Canonical instructions: [`.agents/skills/suggest-code-refactors/SKILL.md`](../../../.agents/skills/suggest-code-refactors/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
