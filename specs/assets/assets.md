# Asset Pipeline

Authoring rules: [`.agents/specs/rules/assets/assets.md`](../../.agents/specs/rules/assets/assets.md).

## Purpose

Catalogued **puzzle solution pictures** (gallery thumbnail and result morph), **fonts**, **mark SFX**, and **music** (bed and solve sting) for the clinical 2D local pack. Board marks and chrome panels are code-drawn from aesthetics—not catalogued art. No 3D, tiles, icons, or voice.

## Asset kinds

| Kind | Applicability | Grounds | Kind specs |
|------|---------------|---------|------------|
| Sprites | N/A — marks are flat form, not sprites | [`view.md`](../view/view.md); [`form.md`](../aesthetics/form.md) | — |
| Tilesets | N/A — no tilemap | [`view.md`](../view/view.md) | — |
| Backgrounds | N/A — Paper chrome only | [`palette.md`](../aesthetics/palette.md) | — |
| 3D models | N/A — 2D space | [`view.md`](../view/view.md) | — |
| Textures and materials | N/A — flat UI | [`aesthetics.md`](../aesthetics/aesthetics.md) | — |
| Animation clips | N/A — procedural motion | [`motion.md`](../aesthetics/motion.md) | — |
| Visual effects | N/A — no VFX set | [`aesthetics.md`](../aesthetics/aesthetics.md) | — |
| Interface art | N/A — type and panels | [`ui-style.md`](../aesthetics/ui-style.md) | — |
| Icons | N/A — no icon set | [`ui-style.md`](../aesthetics/ui-style.md) | — |
| Fonts | Applies | [`ui-style.md`](../aesthetics/ui-style.md) T1/T2 | `fonts` (planned) |
| Sound effects | Applies | [`sound.md`](../aesthetics/sound.md) X1 | `sfx` (planned) |
| Music | Applies | [`sound.md`](../aesthetics/sound.md) M1/M2 | `music` (planned) |
| Voice | N/A — no speech | [`sound.md`](../aesthetics/sound.md) | — |
| Puzzle pictures | Applies | Puzzle thumbnail / solution ([`entities/puzzle.md`](../design/entities/puzzle.md); gallery / result UX; [`perception.md`](../view/perception.md) R5) | `puzzle-pictures` (planned) |

## Sources

| Source type | Applicability | Grounds |
|-------------|---------------|---------|
| AI generation | Applies | Pictures and audio under style series |
| Procedural generation | N/A — no cataloged procedural kind | Hub kinds |
| Third-party | Applies | Licensed geometric sans for T1/T2 |
| Human-made | Applies | Person-supplied / `register-asset` |

## Catalog

- **Catalog root**: TBD — which Integration ADR sets the catalog root (outside engine import)?
- **Asset root**: TBD — which Integration ADR sets the asset root?

Asset IDs, format, and integrity: [`catalog.md`](catalog.md). Fields: [`catalog/fields.md`](catalog/fields.md).

## Lifecycle

| State | Meaning |
|-------|---------|
| draft | Made and cataloged; not yet approved |
| approved | Passed review per **Approval**, or review-exempt; main code may use it |
| deprecated | Retired; main code must not use it |

- **Approval**: `review-asset` Pass alone. A kind may require more, never less. Review-exempt assets approve when the entry merges.
- **Review exemption**: Only a person may exempt an asset, of any source type, from review, recorded in `CAT.F17`. An exempt asset is approved when its entry merges.
- **Use**: Main code uses only approved assets. A gameplay demo uses only cataloged assets with a `review-asset` Pass or a review exemption.

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`ids.md`](ids.md), [`traceability.md`](traceability.md), [`tools.md`](tools.md), [`procedures.md`](procedures.md), [`catalog.md`](catalog.md), [`access.md`](access.md).

- **Procedures**: [`procedures/generate.md`](procedures/generate.md), [`procedures/update.md`](procedures/update.md), [`procedures/touch-up.md`](procedures/touch-up.md), [`procedures/establish-style.md`](procedures/establish-style.md).
- **Kinds**: None yet — planned `puzzle-pictures`, `fonts`, `sfx`, `music`.
