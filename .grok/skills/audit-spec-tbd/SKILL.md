---
name: audit-spec-tbd
description: |-
  Find every TBD (undecided aspect) in specs/, order them upstream first, and
  propose grounded answers for the user to confirm. Confirmed answers go to
  author-spec; unconfirmed ones stay TBD. Use after capture sessions, before a
  spec review, or when the user asks what is still undecided.

  Examples:
    - user: "What's still TBD?" → whole set, suggestions, ask to confirm
    - user: "Resolve the TBDs in the definition" → specs/definition/ only
    - user: "TBD audit for design" → specs/design/, blocking TBDs first
---

# Audit spec TBDs (facade)

Canonical instructions: [`.agents/skills/audit-spec-tbd/SKILL.md`](../../../.agents/skills/audit-spec-tbd/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
