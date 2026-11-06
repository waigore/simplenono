# Feature: line-level fillable shade

Authoring rules: [`.agents/specs/rules/design/features.md`](../../../.agents/specs/rules/design/features.md).

- **Kind**: mechanic
- **Serves**: optional assists distinct from clues ([`../../definition/definition.md`](../../definition/definition.md))
- **Depends on**: [`configuration.md`](../configuration.md) (the line-level fillable option); [`../../technical/schemata/puzzle-def.md`](../../technical/schemata/puzzle-def.md) (F3, F4 line runs)
- **Glossary terms**: [Line-level fillable hint](../glossary/hints.md)

## Purpose

A read-only aid during filling: the player taps a cell and sees the largest run
the line logic still allows through it, to plan fills without touching marks.

## Rules

- **R1**: With the line-level toggle on and the fill tool active, tapping a cell derives
  the shade from the tapped line's runs ([F3](../../technical/schemata/puzzle-def-fields.md),
  [F4](../../technical/schemata/puzzle-def-fields.md)). Over the valid arrangements of that line
  ([`features/fill-hints.md`](fill-hints.md) R1), consider those that fill the tapped
  cell. If none exists, the tap shades nothing. Otherwise the covering run of maximal
  length is the max legal run; where arrangements of that maximal length place it
  differently, the shade covers only the cells they share. It reads line runs only:
  the player's marks never trim or void it.
- **R2**: The shade is an overlay: it never writes or changes marks and shows at most one
  region at a time. A new tap recomputes per R1 and replaces it.
- **R3**: The shade clears when the line-level toggle turns off, the fill tool stops
  being active, or the attempt ends; it is not persisted.
- **R4**: Toggling applies immediately like the other assists ([`features/fill-hints.md`](fill-hints.md) R4);
  this assist derives live ([R1]) and is never cached ([SCH-puzzle-def](../../technical/schemata/puzzle-def.md) F8/F9 untouched).

## Parameters

- Line-level fillable hint option ([configuration.md](../configuration.md); default off).
- Shade colour: [palette](../../aesthetics/palette.md) C9 owns the swatch ([K7](../../aesthetics/palette.md)),
  lighter than the fill-hint overlay colour (C8). The approved [MC.puzzle](../../ux/mockups/screens/puzzle.html)
  legends lock it at `#C2CDD4` ([`PER.R8`](../../view/perception.md)).

## State

| Field | Read / write | When |
|-------|--------------|------|
| Hint preference toggles | read | gating the shade ([R1], [R3]) |
| [SCH-puzzle-def](../../technical/schemata/puzzle-def.md) F3/F4 | read | per-tap derivation |
| Tool selection | read | fill active check ([R1], [R3]) |

## Interactions with other features

- **I1**: The shade is the third assist of the hint class; enabling it during an active
  attempt is observable so hint-free voids ([SCH-preferences](../../technical/schemata/preferences.md) F4-F6; [ADR-0010](../../adr/decisions/0010-hint-preferences.md)).
- **I2**: At most one shade region renders at a time ([R2]); overlays from
  [`features/fill-hints.md`](fill-hints.md) [R3] may coexist; the colours stay distinct.

## Edge cases

| ID | Situation | Outcome |
|----|-----------|---------|
| X1 | Tap on a cell no valid arrangement fills | No shade shows for that tap |
| X2 | Tap on a cell already marked | The mark stands untouched; the shade overlays it |
| X3 | A mark is placed while a shade shows | The shade holds until [R3] clears it or the next tap recomputes ([R2]) |

## Difficulty and configuration effects

- **D1**: The line-level option changes only the shade ([R1]); no option changes solve rules ([configuration.md](../configuration.md)).

## Experience intent

The player feels the shade as a quiet reading of what the line still permits:
planning integrity without hints writing the board.
