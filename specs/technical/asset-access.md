# Asset Access (Technical)

Authoring rules: [`.agents/specs/rules/technical/asset-access.md`](../../.agents/specs/rules/technical/asset-access.md).

- **Serves**: Product access rules for fonts, SFX, music, and puzzle pictures ([`ACC`](../assets/access.md)); offline local pack ([`definition.md`](../definition/definition.md)).
- **Informed by**: [`specs/assets/access.md`](../assets/access.md); [`assets.md`](../assets/assets.md)
- **ADRs**: TBD — Engine ADR; Integration ADR for catalog root and asset root

## Resolution

| ID | Aspect | Realizes | Rule |
|----|--------|----------|------|
| R1 | Asset manifest | `ACC.A2` | TBD — format, location outside asset root, generator, and regenerate-when from the Integration ADR that sets catalog/asset roots? |
| R2 | Resolver | `ACC.A1` | TBD — which `CMP-` owns reading the manifest (awaits Engine ADR / module map)? |
| R3 | Unresolved asset ID | `ACC.A3` | Dev: loud fail / assert on resolve. Release: build fails if the manifest lists a missing, draft, or deprecated ID used by shipped code. |

## Engine resources

| ID | Resource class | Lives in | Uses | Kept in step by |
|----|----------------|----------|------|-----------------|
| E1 | TBD — Godot resources that reference cataloged assets (scenes, AudioStream players, Theme/font) | Outside asset root (TBD — Engine ADR path) | G1–G3 asset IDs | TBD — generated or checked against manifest (Integration ADR)? |

## Build outputs

| ID | Output | Generator | Inputs | Location | Committed |
|----|--------|-----------|--------|----------|-----------|
| O1 | TBD — import cache / bundled copies from asset root | TBD — Engine / Integration ADR | `ACC.G1`–`G3` | Outside asset root | TBD — rebuilt vs committed? |

## Load groups

| ID | Realizes | Mechanism | Owner | Sequence |
|----|----------|-----------|-------|----------|
| G1 | `ACC.G1` | TBD — preload list or bootstrap load (Engine ADR) | TBD — `CMP-` | Load at app start; no unload |
| G2 | `ACC.G2` | TBD — stream or preload bed; sting one-shot on result | TBD — `CMP-` | Load with gallery/puzzle; sting on result; mute bed only per settings |
| G3 | `ACC.G3` | TBD — on-demand or pack-indexed load | TBD — `CMP-` | Resolve the generated and pixel picture ids by puzzle identity; unload when unused |

## Diagram

None yet — groups do not overlap densely; add Mermaid when mechanisms are set by ADR.
