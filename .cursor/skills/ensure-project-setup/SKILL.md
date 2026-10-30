---
name: ensure-project-setup
description: |-
  Check whether first-time setup of a repo created from this template is done,
  and complete whatever is missing by delegating to the supporting skills.
  Use at the start of a new project, before capturing requirements or opening
  the first PR, or when the user asks whether setup is done.

  Examples:
    - user: "I just created this repo from the template" → check, apply gaps, report
    - user: "Is first-time setup done?" → check, apply gaps, report
    - capture-requirements: step 0 → check; continue only when setup passes
---

# Ensure project setup (facade)

Canonical instructions: [`.agents/skills/ensure-project-setup/SKILL.md`](../../../.agents/skills/ensure-project-setup/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
