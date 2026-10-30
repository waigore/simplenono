# Asset Pipeline

Authoring rules: [`.agents/specs/rules/assets/assets.md`](../../.agents/specs/rules/assets/assets.md).

## Purpose

<!-- fill in -->

## Asset kinds

| Kind | Applicability | Grounds | Kind specs |
|------|---------------|---------|------------|
| Sprites | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
| Tilesets | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
| Backgrounds | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
| 3D models | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
| Textures and materials | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
| Animation clips | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
| Visual effects | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
| Interface art | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
| Icons | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
| Fonts | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
| Sound effects | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
| Music | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |
| Voice | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |

## Sources

| Source type | Applicability | Grounds |
|-------------|---------------|---------|
| AI generation | <!-- fill in --> | <!-- fill in --> |
| Procedural generation | <!-- fill in --> | <!-- fill in --> |
| Third-party | <!-- fill in --> | <!-- fill in --> |
| Human-made | <!-- fill in --> | <!-- fill in --> |

## Catalog

- **Catalog root**: <!-- fill in -->
- **Asset root**: <!-- fill in -->

Asset IDs, format, and integrity: [`catalog.md`](catalog.md). Fields: [`catalog/fields.md`](catalog/fields.md).

## Lifecycle

| State | Meaning |
|-------|---------|
| draft | Made and cataloged; not yet approved |
| approved | Passed review per **Approval**, or review-exempt; main code may use it |
| deprecated | Retired; main code must not use it |

- **Approval**: <!-- fill in -->
- **Review exemption**: Only a person may exempt an asset, of any source type, from review, recorded in `CAT.F17`. An exempt asset is approved when its entry merges.
- **Use**: Main code uses only approved assets. A gameplay demo uses only cataloged assets with a `review-asset` Pass or a review exemption.

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`ids.md`](ids.md), [`traceability.md`](traceability.md), [`tools.md`](tools.md), [`procedures.md`](procedures.md), [`catalog.md`](catalog.md), [`access.md`](access.md).

- **Procedures (split)**: [`procedures/generate.md`](procedures/generate.md), [`procedures/update.md`](procedures/update.md), [`procedures/touch-up.md`](procedures/touch-up.md), [`procedures/establish-style.md`](procedures/establish-style.md).
- **Kinds**: <!-- fill in: links, or None yet — copy kinds/_template.md -->
