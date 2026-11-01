# Asset Pipeline Traceability

Authoring rules: [`.agents/specs/rules/assets/traceability.md`](../../.agents/specs/rules/assets/traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Cool clinical look; calm tactile grid; snappy solve | vision | [`assets.md`](assets.md); planned kinds |
| Local 2D pack; offline play; free-order gallery | definition | [`assets.md`](assets.md); [`access.md`](access.md) |
| Hitch-bound / frame-time | quality | [`access.md`](access.md) G1 |
| Puzzle thumbnail and solution picture | design | [`kinds/puzzle-pictures.md`](kinds/puzzle-pictures.md); [`access.md`](access.md) G3 |
| 2D fixed board; win reveal R5 | view | [`assets.md`](assets.md); [`access.md`](access.md) G3 |
| Medium, pillars, sound M1/M2/X1; UI type T1/T2 | aesthetics | [`kinds/puzzle-pictures.md`](kinds/puzzle-pictures.md); [`kinds/fonts.md`](kinds/fonts.md); [`kinds/sfx.md`](kinds/sfx.md); [`kinds/music.md`](kinds/music.md) |
| Gallery, puzzle, result, settings (mute bed) | ux | [`access.md`](access.md) G1–G3 |
| No market license mandates | definition | Sources table in [`assets.md`](assets.md) |

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Asset kinds | [`assets.md`](assets.md), [`kinds/`](kinds/) | Applies — `puzzle-pictures`, `fonts`, `sfx`, `music` |
| AI generation | [`tools.md`](tools.md), [`kinds/`](kinds/) | Applies — hub Sources |
| Procedural generation | [`tools.md`](tools.md), [`kinds/`](kinds/) | N/A — hub Sources |
| Third-party sourcing | [`procedures.md`](procedures.md), [`kinds/`](kinds/) | Applies — licensed font |
| Human-made assets | [`procedures.md`](procedures.md), [`catalog.md`](catalog.md) | Applies — register path |
| Tool roles | [`tools.md`](tools.md) | Applies — TL.1/TL.2 for puzzle pictures |
| Procedures | [`procedures.md`](procedures.md) | Applies — template procedures |
| Catalog | [`catalog.md`](catalog.md) | Applies — roots [ADR-0003](../adr/decisions/0003-catalog-asset-roots.md) |
| Asset access and load groups | [`access.md`](access.md) | Applies |
| Sound assets | [`kinds/sfx.md`](kinds/sfx.md), [`kinds/music.md`](kinds/music.md) | Applies |
| Localized assets | [`kinds/`](kinds/) | N/A — localization not yet Applies in quality |
| Accessible variants | [`kinds/`](kinds/) | N/A — accessibility not yet Applies in quality |
