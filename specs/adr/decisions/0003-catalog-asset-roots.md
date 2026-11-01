# ADR-0003: Catalog and asset roots

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-11-01
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Asset hub catalog and access ([`assets.md`](../../assets/assets.md), [`access.md`](../../assets/access.md), [`catalog.md`](../../assets/catalog.md)). Offline Godot project ([ADR-0001](0001-godot-gdscript.md)). Technical asset access ([`asset-access.md`](../../technical/asset-access.md)).

## Context

The asset hub and technical access already define kinds, IDs, and load groups, but catalog root, asset root, manifest, and Godot project path are still unset. Code and CI need fixed paths before cataloging or loading.

## Purpose

Where the Godot project, catalog entries, cataloged files, and the asset manifest live, and who regenerates the manifest. In scope: those roots, manifest format and regenerate-when, and the resolver owner. Out of scope: generation tools, puzzle pack data layout, and save location ([ADR-0002](0002-user-data-dir.md)).

## Decision

- **Godot project**: `game/` (the `project.godot` tree; `res://` is that folder).
- **Catalog root**: `assets/catalog/` at the repo root (outside `game/`; never imported).
- **Asset root**: `game/assets/` (under `res://`; only cataloged files and Godot `.import` sidecars).
- **Catalog format**: the default in [`catalog.md`](../../assets/catalog.md) (one `<asset-id>.json` per entry).
- **Asset manifest**: generated JSON at `assets/manifest.json` (outside the asset root; never hand-edited). Maps each approved asset ID to `res://` path(s) under the asset root.
- **Regenerate when**: a catalog entry is added, changed, or deprecated, and in CI when those paths change.
- **Resolver**: [`CMP-shell`](../../technical/components/shell.md) alone reads the manifest at runtime.

## Reasoning

1. Catalog outside import. Repo-root `assets/catalog/` never becomes a Godot resource.
2. Files under `res://`. `game/assets/` gets import sidecars where the engine expects them.
3. Manifest outside the asset root. Matches [`ACC.P2`](../../assets/access.md); CI can regenerate without touching playables.
4. Shell resolves. Presentation already owns load groups G1–G3.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Godot project at repo root | Would pull catalog JSON and template docs into `res://` or need many ignores |
| Asset root at `assets/files/` outside `game/` | Godot would not import without copy or link steps |
| Hand-edited manifest | Breaks [`ACC.A2`](../../assets/access.md) |
| Pack or attempt as resolver | Load groups are presentation, not play or records |

## Non-functional requirements

Tables: [`non-functional.md`](0003-catalog-asset-roots/non-functional.md).

### Quality expectations

`frame-time` and `hitch-bound` stay as set. Load-time targets in quality stay unset; this ADR does not set them.

### Engineering qualities

Paths and JSON only; no new licensed dependency. The five definition platforms stay in scope.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`assets.md`](../../assets/assets.md) | Catalog root `assets/catalog/`; asset root `game/assets/` |
| [`asset-access.md`](../../technical/asset-access.md) | Manifest, resolver, load mechanisms, and engine placement per Decision |
| [`CMP-shell`](../../technical/components/shell.md) | Sole runtime reader of `assets/manifest.json` |
| [`kinds/puzzle-pictures.md`](../../assets/kinds/puzzle-pictures.md) | Files under `game/assets/` from handle |

## Validation

| Check | Method | When |
|-------|--------|------|
| Catalog and asset roots match this ADR | CI `asset_catalog.py` | every build once roots exist |
| Manifest is generated, not hand-edited | review rule + CI | every build |
| Runtime resolve goes only through CMP-shell | review rule | before acceptance |
