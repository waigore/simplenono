# Authoring rules: asset access

Read this before editing `specs/assets/access.md`. Do not copy these rules into the spec.

Also read [assets.md](assets.md), [ids.md](ids.md), and [catalog.md](catalog.md).

How the game reaches its assets, in product terms: how code and data name an asset, what may live under the asset root, and which assets are loaded together and when. No engine, product, or format names. Its technical counterpart, `specs/technical/asset-access.md`, realizes it in code per [`../technical/asset-access.md`](../technical/asset-access.md).

## Paired with the technical counterpart

Fill this file in the same change as the asset hub, and fill the technical counterpart in that change too. Values that depend on an ADR not yet Accepted are `TBD — <question>` in the counterpart, naming the ADR they wait on; the Integration ADR that sets the asset root resolves them. Change either file, and check the other in the same change.

## Header

- **Serves**: vision qualities, definition items, quality targets (load time, memory), and design, view, or UX specs.
- **Technical counterpart**: a link to `specs/technical/asset-access.md`.

## Sections

- **Addressing**: `A1`, `A2`, …. Keep the skeleton rows as written: `A1` code and data name an asset only by its asset ID, never by file path or handle; `A2` an asset manifest generated from the catalog, never hand-edited, maps each asset ID to its files, and the asset manifest main code uses lists only approved entries. Fill `A3`: what happens when an asset ID cannot be resolved (unknown, draft, or deprecated) in development and in a release, in product terms, citing a quality or UX element. Add rows for any other addressing rule.
- **Placement**: `P1`, `P2`, …. Keep the skeleton rows as written: `P1` the asset root holds only cataloged asset files and the engine's import sidecars; `P2` engine resources and build outputs live outside the asset root, are not cataloged, and are listed in the technical counterpart.
- **Load groups**: `G1`, `G2`, …. Columns: group, members (asset IDs, kind specs, or coverage rules such as `AK-character-sprites.V2`), load point, unload point, and serves. Load and unload points cite design, view, or UX elements, such as a stage, a mode, or a screen. Every asset main code uses belongs to at least one group, or one row states the default (such as "load on first use, never unload"). Each group, or the default, fits the load-time and memory targets in `specs/definition/quality.md`; cite them.

When every asset kind in the hub is N/A, write "None — no asset kind applies" under each section, and mark the technical counterpart's sections the same way.
