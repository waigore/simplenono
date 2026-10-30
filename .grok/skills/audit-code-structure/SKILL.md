---
name: audit-code-structure
description: |-
  Audit implementation code for structure and technical debt against
  docs/solid.md, docs/coding-conventions.md, structure continuity, and four
  smells (duplication, dead code, awkward seams, parallel structure). Each
  finding includes a proposed target or a decision the target needs. Read-only.
  Use for the whole implementation tree or a named portion, when the user wants
  findings without filing issues, or when suggest-code-refactors asks for the audit.

  Examples:
    - user: "Audit structure, don't file issues" → whole tree except pocs/
    - user: "Audit src/combat" → that portion
    - suggest-code-refactors: pass the request scope, return this report
---

# Audit code structure (facade)

Canonical instructions: [`.agents/skills/audit-code-structure/SKILL.md`](../../../.agents/skills/audit-code-structure/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
