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

# Manage asset

Veneer over [`specs/assets/procedures.md`](../../../specs/assets/procedures.md) and the procedure file it links. Style: [`specs/aesthetics/`](../../../specs/aesthetics/aesthetics.md). Review: [`review-asset`](../review-asset/SKILL.md). Style series: [`establish-asset-style`](../establish-asset-style/SKILL.md). Do not restate prompt composition, series binding, catalog fields, or review approval.

## Steps

1. **Gate**. Stop, say what is missing, and offer `capture-requirements`, `author-spec`, `audit-spec-tbd`, or `establish-asset-style` when any of these fails:
   - The asset hub's **Catalog** names a catalog root and asset root (no TBD), and **Approval** is filled.
   - The target kind spec exists. Its coverage rule, specification, recipe, checks, and Style series hold no placeholder or TBD for the work requested.
   - Every aesthetics element the kind cites exists and holds no TBD.
   - The recipe's tool role in `specs/assets/tools.md` is realized by an **Accepted** ADR, or by an ADR-free tool named in [`docs/asset-tools.md`](../../../docs/asset-tools.md). Prefer tools per that doc. When the kind Style series is `active`, use Recraft (visual) or the ElevenLabs CLI (music / SFX / voice; never MCP). Do not use fal or Cheaper Inference for series-active work.
   - Full series generate or update needs Style series `active` with the modality binding (hard id, or soft anchors for SFX). If `none` or `bootstrapping`, only bootstrap seed runs, or hand off to `establish-asset-style`. If `stale`, refresh via `establish-asset-style` first.
2. **Resolve the request** to one procedure (`APR.generate`, `APR.import`, `APR.update`, `APR.deprecate`, or `APR.touch-up`), the kind spec, coverage rules, and asset IDs. If no coverage rule requires the asset, stop: spec first.
3. **Confirm scope** with the user when the request spans more than one coverage rule or would exceed a cost or quota limit in `tools.md`.
4. **Start** per [`references/change-pr.md`](references/change-pr.md) (before editing). With no issue, branch `chore/assets-<slug>`.
5. **Run the procedure** as written. **Cheaper Inference**, when the recipe or tool preference selects it and the series is not `active`: follow [`docs/asset-tools-cheaperinference-steps.md`](../../../docs/asset-tools-cheaperinference-steps.md) exactly. Prefer `python3 .github/scripts/cheaperinference_image.py` (`generate` or `reference`). Do not call `/v1/images/edits` for `flux-2-max` or invent model display names.
6. **PR** per [`references/change-pr.md`](references/change-pr.md) (after editing). Apply the PoC ask when the run is for a PoC under `pocs/`. Authority cites kind, coverage, aesthetics, style series, and tool ADRs (`adr-free` when applicable). Test plan: checks, touch-ups, `asset_catalog.py`, and the `review-asset` verdict.

## Rules

- Never invent a recipe, prompt, setting, style choice, coverage rule, or style-binding id. Missing ones go into specs or `establish-asset-style` first.
- Use only Accepted ADR tools, ADR-free / touch-up options in `docs/asset-tools.md`, or the modality-required tool for active series. Audio via ElevenLabs is CLI-only ([`docs/asset-tools-elevenlabs.md`](../../../docs/asset-tools-elevenlabs.md)); never an ElevenLabs MCP. Never a banned tool. Credentials never enter the repository.
- Do not import a third-party asset whose license is unclear; stop and ask.
- Main code uses only approved assets. Do not wire a draft into main code.
- Person-supplied assets go through [`register-asset`](../register-asset/SKILL.md). Style series establish goes through [`establish-asset-style`](../establish-asset-style/SKILL.md).
- Never change or reuse an asset ID; rename a handle only on request, per `catalog.md`.
