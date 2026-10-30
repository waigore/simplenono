---
name: audit-project-wave
description: |-
  Audit a filed wave (milestone) against the waves contract: epics and defined
  tasks for coherence, focus, completeness, and quality. Propose changes;
  confirm before mutating. Use after plan-project-waves, when a wave looks
  bloated or incomplete, or before expanding leaves.

  Examples:
    - user: "Audit wave 1" → load wave, findings + proposed changes, wait
    - user: "Draft wave audit only" → --no-create, print package
    - user: "Apply the wave 2 fixes" → confirm then mutate
---

# Audit project wave (facade)

Canonical instructions: [`.agents/skills/audit-project-wave/SKILL.md`](../../../.agents/skills/audit-project-wave/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
