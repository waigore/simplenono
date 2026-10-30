---
name: sync-upstream-template
description: |-
  Merge changes from the upstream template into a repo created from it. Finds
  the last-synced upstream commit, classifies each upstream-changed file by
  comparing it with the downstream copy, takes upstream for untouched
  template files, 3-way merges files edited on both sides (confirming
  conflicts with the user), and opens one sync PR.
  Use when the user asks to pull, merge, sync, or update from the template
  or upstream.

  Examples:
    - user: "Merge the latest template changes" → upstream main, sync PR
    - user: "Sync from the template up to v1.2" → that tag as the target
    - user: "What would a template update change?" → plan only, no PR
---

# Sync upstream template (facade)

Canonical instructions: [`.agents/skills/sync-upstream-template/SKILL.md`](../../../.agents/skills/sync-upstream-template/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
