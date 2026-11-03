---
name: migrate-playtest-evidence-to-wiki
description: |-
  Move in-repo playtest screenshots and logs to the GitHub wiki, rewrite
  manifests to cite the wiki page URL, delete local media dirs, confirm
  gitignore, and open a focused PR. Use when a child repo still stores
  playtest media under docs/playtest/evidence/, or when the user asks to
  migrate playtest evidence off git.

  Examples:
    - user: "Migrate playtest evidence to the wiki" → wiki push, manifest rewrite, PR
    - user: "Move screenshots out of docs/playtest/evidence" → same
    - user: "What would migration change?" → inventory only, no PR
---

# Migrate playtest evidence to wiki (facade)

Canonical instructions: [`.agents/skills/migrate-playtest-evidence-to-wiki/SKILL.md`](../../../.agents/skills/migrate-playtest-evidence-to-wiki/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
