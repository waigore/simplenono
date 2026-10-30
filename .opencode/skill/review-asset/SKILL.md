---
name: review-asset
description: |-
  Review produced assets against their kind spec in specs/assets/ and the
  style in specs/aesthetics/: catalog record, style series binding,
  structured generation, specification, budgets, kind checks, style pillars,
  visual palette/hierarchy/silhouette/contrast or audio SND character/mix,
  readability or listenability, content limits, and license. Pass/Fail with
  findings tagged by element ID. Read-only.
  Use from manage-asset after generation, from verify-project-issue when a PR
  adds or changes assets, or on demand.

  Examples:
    - user: "Review the new player sprites" → those asset IDs, report in chat
    - user: "Review the new UI click SFX" → listen checks vs SND.X / series
    - manage-asset: drafts ready → review, return verdict to the caller
    - verify-project-issue: PR #40 adds assets → review the PR's catalog changes
---

# Review asset (facade)

Canonical instructions: [`.agents/skills/review-asset/SKILL.md`](../../../.agents/skills/review-asset/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
