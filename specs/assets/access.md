# Asset Access

Authoring rules: [`.agents/specs/rules/assets/access.md`](../../.agents/specs/rules/assets/access.md).

- **Serves**: <!-- fill in -->
- **Technical counterpart**: [`specs/technical/asset-access.md`](../technical/asset-access.md)

## Addressing

| ID | Rule |
|----|------|
| A1 | Code and data name an asset only by its asset ID, never by file path or handle. |
| A2 | An asset manifest generated from the catalog, never hand-edited, maps each asset ID to its files. The asset manifest main code uses lists only approved entries. |
| A3 | <!-- fill in: what happens when an asset ID cannot be resolved, in development and in a release --> |

## Placement

| ID | Rule |
|----|------|
| P1 | The asset root holds only cataloged asset files and the engine's import sidecars. |
| P2 | Engine resources and build outputs live outside the asset root, are not cataloged, and are listed in the technical counterpart. |

## Load groups

| ID | Group | Members | Load point | Unload point | Serves |
|----|-------|---------|------------|--------------|--------|
| G1 | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
