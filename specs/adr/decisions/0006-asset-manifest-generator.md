# ADR-0006: Asset manifest generator

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-11-01
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Manifest and regenerate-when rules left tool-open by [ADR-0003](0003-catalog-asset-roots.md); [`ACC.A2`](../../assets/access.md), [`assets.md`](../../assets/assets.md); offline play ([`definition.md`](../../definition/definition.md)); engine release unpinned ([ADR-0001](0001-godot-gdscript.md)); headless repo-tooling precedent ([ADR-0005](0005-gut-unit-tests.md)); authoring / CI scripts pattern ([`tools.md`](../../assets/tools.md) TL.2).

## Context

[ADR-0003](0003-catalog-asset-roots.md) fixes the manifest format, its place outside the asset root, its never-hand-edited status, and the regenerate trigger: catalog entries added, changed, or deprecated, and CI when those paths change. It named no generator; [`specs/technical/asset-access.md`](../../technical/asset-access.md) R1 waits on this decision. The manifest maps approved asset IDs to `res://` paths under `game/assets/`; the game installs and runs offline, and the Godot release is unpinned.

## Purpose

Which tool generates and regenerates the asset manifest. In scope: the generator, where it lives, when it runs, and how CI keeps the committed file honest. Out of scope: manifest format, catalog root, and asset root ([ADR-0003](0003-catalog-asset-roots.md)); the runtime resolver (`CMP-shell`); catalog tool roles (TL.1–TL.4).

## Decision

- **Generator**: `asset_manifest.py` under `.github/scripts/`, beside the catalog checker.
- **Input and output**: reads the approved entries in `assets/catalog/` and the cataloged files under `game/assets/`, and overwrites `assets/manifest.json` as one whole file. Human edits are not a change mechanism.
- **When it runs**: locally in the same change that adds, changes, or deprecates a catalog entry or moves cataloged files; the asset CI job runs it on every PR touching those paths, and a committed manifest differing from a regenerated one fails the build.
- **No coupled machinery**: deterministic, offline — no network, no API keys, no Godot binary or editor; asset approval stays with the catalog and its reviews.

## Reasoning

1. **Offline CI**: JSON derivation needs no network or keys ([`definition.md`](../../definition/definition.md)); CI stays free.
2. **Unpinned engine**: a version-independent script keeps this data transform off the Godot build ([ADR-0001](0001-godot-gdscript.md)).
3. **Existing pattern**: the same inputs are already validated every build by the CI catalog checker ([ADR-0003](0003-catalog-asset-roots.md)); [ADR-0005](0005-gut-unit-tests.md) sets the precedent.
4. **Reviewable artifact**: the manifest stays committed, so `ACC.A3` release checks fail builds in the open.
   Costs accepted: Python beside GDScript; the script is a second reader of the catalog format.

## Rejected alternatives

Moved to [`0006-asset-manifest-generator/non-functional.md`](0006-asset-manifest-generator/non-functional.md) — a table: headless Godot generator (engine coupling), generate-at-export (breaks the CI trigger and offline debug), hand-edited manifest (ADR-0003 rejected it).

## Non-functional requirements

Tables: [`non-functional.md`](0006-asset-manifest-generator/non-functional.md).

### Quality expectations

No effect on product quality targets.

### Engineering qualities

No dependency; deterministic, headless, offline.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`asset-access.md`](../../technical/asset-access.md) | R1's manifest row names the generator per Decision; its open question is closed |
| [`adr.md`](../adr.md) | Integrations stack row covers the manifest generator |

## Validation

| Check | Method | When |
|-------|--------|------|
| Committed manifest matches a regeneration from the catalog | CI `asset_manifest.py` beside the catalog checker | every build once the script exists |
| Manifest stays generated, not hand-edited | review rule + CI drift check | every build |
