---
name: audit-spec-applicability
description: |-
  Audit Applies/N/A consistency for a quality category, design topic, or the
  whole spec set: ground each claim upstream and check required carry-outs
  downstream. Use when quality depends on features, after scope/design changes,
  or before a whole-spec review. Read-only; report mismatches for author-spec.

  Examples:
    - user: "Does save durability apply?" → upstream scope/progression + downstream
    - user: "Audit observability applicability" → quality ↔ ADRs ↔ technical
    - user: "Applicability audit for the whole spec" → all coverage/quality tables
---

# Audit spec applicability (facade)

Canonical instructions: [`.agents/skills/audit-spec-applicability/SKILL.md`](../../../.agents/skills/audit-spec-applicability/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
