---
name: ensure-open-design-skill-setup
description: |-
  Ensure the Open Design skill wrapper (sugarforever/open-design-skill) and
  content repo (nexu-io/open-design) are git-cloned under ~/.open-design-skill/,
  pull latest, verify, then ask whether to symlink as user-local skills for
  Cursor / OpenCode / Grok. Use only when the user asks; do not run as a gate
  for other skills. Never wire into the project skill trees.

  Examples:
    - user: "Set up Open Design" → clone/pull home paths, verify, ask wiring, report
    - user: "Is open-design-skill installed?" → pull, verify, report; ask wiring if missing
    - user: "Wire Open Design into Cursor" → ensure home install, then wire chosen agents
---

# Ensure Open Design skill setup (facade)

Canonical instructions: [`.agents/skills/ensure-open-design-skill-setup/SKILL.md`](../../../.agents/skills/ensure-open-design-skill-setup/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
