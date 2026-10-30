---
name: register-asset
description: |-
  Catalog an asset a person supplies (made by hand, generated with their own
  AI or procedural tool, or bought) by running APR.register in specs/assets/:
  a collision-free asset ID, source type, supplier, rights or license, files
  under the asset root, and an optional review exemption that only that
  person can grant. Exempt assets are approved on merge; others go through
  review-asset. Opens a PR.
  Use when the user hands over art, animation, interface art, fonts, or audio
  they or a teammate made, generated, or bought, and wants it in the catalog.

  Examples:
    - user: "I drew the player idle sprite, add it" → register, ask about exemption, PR
    - user: "Add my title music, skip review" → register with exemption by the user
    - user: "Register these purchased SFX, review them" → register, license check, review-asset
    - user: "I made this tileset with an AI tool, add it" → source type AI generation, tool terms, ask about exemption
---

# Register asset (facade)

Canonical instructions: [`.agents/skills/register-asset/SKILL.md`](../../../.agents/skills/register-asset/SKILL.md).

Read that file, then run the workflow there. Do not invent a parallel process.
