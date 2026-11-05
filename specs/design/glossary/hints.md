# Glossary: hint assists

Authoring rules: [`.agents/specs/rules/design/glossary.md`](../../../.agents/specs/rules/design/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Fill hint | Precomputed forced-cell content shown as an overlay over the [cell](../entities/cell.md) marks; never writes marks. | [`../features/fill-hints.md`](../features/fill-hints.md) |
| Hint-free | Per-puzzle clean-solve flag; voided if any hint is enabled during an active attempt (even unused); re-earned on a later clean solve; cleared on gallery reset. | [`../progression.md`](../progression.md), [`../end-conditions.md`](../end-conditions.md) |
| Line-level fillable hint | Assist that, with the fill tool active, shades the max legal run containing the tap in a lighter colour, or nothing when no such run exists. | [`../features/line-fillable-shade.md`](../features/line-fillable-shade.md), [`../configuration.md`](../configuration.md) |
| Multi-line fill hint | [Fill hint](hints.md) showing the precomputed one-level multi-line forced cells ([F9](../../technical/schemata/puzzle-def-fields.md)). | [`../features/fill-hints.md`](../features/fill-hints.md), [`../configuration.md`](../configuration.md) |
| Single-line fill hint | [Fill hint](hints.md) showing the precomputed single-line forced cells ([F8](../../technical/schemata/puzzle-def-fields.md)). | [`../features/fill-hints.md`](../features/fill-hints.md), [`../configuration.md`](../configuration.md) |
