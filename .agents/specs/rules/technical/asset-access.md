# Authoring rules: asset access (technical)

Read this before editing `specs/technical/asset-access.md`. Do not copy these rules into the spec.

Also read [technical.md](technical.md), [ids.md](ids.md), and [`../assets/access.md`](../assets/access.md).

Realizes `specs/assets/access.md` in code and data: the asset manifest's format and location, the resolver, the engine resources and build outputs, and the mechanism behind each load group. The asset access spec owns the rules in product terms; this file owns how the engine meets them. Do not restate its rules.

## Paired with the asset access spec

A standard file in the template, not an optional global. Fill it in the same change as `specs/assets/access.md`, which is filled with the asset hub. This is the one technical file written before the ADRs it depends on: each value that depends on an ADR not yet Accepted is `TBD — <question>`, naming that ADR (usually the Engine ADR or the Integration ADR that sets the asset root). Replace those TBDs once the ADR is Accepted. A cited `CMP-`, `MOD-`, or `SEQ-` element that does not exist yet is also TBD.

When every asset kind in the hub is N/A, write "None — no asset kind applies" under each section.

## Header

- **Serves**, **Informed by**, **ADRs**: as in [components.md](components.md). **Informed by** always cites `specs/assets/access.md`.

## Sections

- **Resolution**: `R1`, `R2`, …. Keep three rows: `R1` the asset manifest (format per the Integration ADR, location outside the asset root, the tool that generates it, and when it is regenerated) realizing `ACC.A2`; `R2` the resolver, the one component that reads the asset manifest, cited by `CMP-` ID, realizing `ACC.A1`; `R3` how an unresolved asset ID is handled, realizing `ACC.A3`. Add rows as needed.
- **Engine resources**: `E1`, `E2`, …. Files authored in the engine's own formats that use cataloged assets, such as animation sets, prefabs, materials, scenes, and animation controllers. Columns: resource class, where it lives (a module, outside the asset root), the asset IDs or kinds it uses, and how it stays in step with the asset manifest when the engine format stores a path (generated from it, or checked against it). Write "None — reason" when the engine needs none.
- **Build outputs**: `O1`, `O2`, …. Files the engine or build tooling generates from cataloged assets, such as atlases, import caches, and bundles. Columns: output, generator (cite the ADR), inputs (asset IDs, kinds, or `ACC.G` groups), location outside the asset root, and whether it is committed or rebuilt. Never hand-edited. Write "None — reason" when nothing is generated.
- **Load groups**: `G1`, `G2`, …. One row per `ACC.G` group: the group it realizes, the mechanism (such as a preload list or a bundle), the owning component, and the sequence that loads and unloads it.
- **Diagram**: required when load groups overlap or follow a dense flow. Mermaid or link under `diagrams/`.
