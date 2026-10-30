---
name: manage-asset
description: |-
  Generate, import, update, or deprecate game assets by running the asset
  pipeline procedures in specs/assets/ against the style in specs/aesthetics/,
  record every change in the catalog's entry files, get each draft reviewed with
  review-asset, and open a PR. Spec first: only assets a coverage rule
  requires, through tool roles realized by Accepted ADRs or ADR-free tools in
  docs/asset-tools.md (Recraft for visual gen/edit/touch-up and style series;
  Cheaper Inference ADR-free for non-series visual gen/reference via locked
  steps + cheaperinference_image.py; ElevenLabs CLI for music/SFX/voice and
  audio style series — never MCP; fal needs an ADR and is not used when the
  kind series is active). Never a banned tool.
  Use when the user asks to create, generate, source, regenerate, replace,
  touch up, or retire art, animation, interface art, fonts, or audio.
  For establishing a kind's style series, use establish-asset-style.

  Examples:
    - user: "Generate the player run sprites" → APR.generate from the kind recipe, checks, review, PR
    - user: "Generate the menu theme with the music series" → ElevenLabs CLI + finetune_id
    - user: "Use this licensed tileset for the forest" → APR.import, license check, catalog, review
    - user: "Regenerate the slime with the new palette" → APR.update, version bump, re-review
    - user: "Retire the old HUD icons" → APR.deprecate with successor IDs
    - user: "Remove the background on the slime sprite" → APR.touch-up, re-check, re-review
---

# Manage asset (facade)

Canonical instructions: [`.agents/skills/manage-asset/SKILL.md`](../../../.agents/skills/manage-asset/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
