---
name: capture-requirements
description: |-
  Capture requirements via guided questions derived from each spec's authoring
  rules and template placeholders, confirm answers with the user, then hand off
  to author-spec. Specifying is the default: a game idea starts with the
  blocking fields, then one spec file the user picks. They may revise a written
  requirement. A PoC starts only when they ask to explore a named uncertainty.
  Use when interviewing for any spec, or when the user asks to capture
  requirements, gather requirements, or fill a spec by asking questions.

  Examples:
    - user: "Help me capture requirements" → interview unset blocking fields
    - user: long prompt with pitch, platforms, and combat rules → interview the foundation; save combat as a note until they pick that file
    - user: "Help me fill definition by asking questions" → specs/definition/definition.md only
    - user: "Specify movement" while pitch is unset → blocking fields and the movement spec, one confirmation
    - user: "Capture requirements for design and view" → ask which one file this run
    - user: "Change the win condition" → revision; show specs that cite it
    - user: "Explore movement before deciding it" → scope-poc; do not interview
---

# Capture requirements (facade)

Canonical instructions: [`.agents/skills/capture-requirements/SKILL.md`](../../../.agents/skills/capture-requirements/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
