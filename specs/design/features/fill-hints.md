# Feature: fill hints

Authoring rules: [`.agents/specs/rules/design/features.md`](../../../.agents/specs/rules/design/features.md).

- **Kind**: mechanic
- **Serves**: optional assists distinct from clues ([`../../definition/definition.md`](../../definition/definition.md)); local pack ([`entities/puzzle.md`](../entities/puzzle.md))
- **Depends on**: [`configuration.md`](../configuration.md) (the three assist options); [`../../technical/schemata/puzzle-def.md`](../../technical/schemata/puzzle-def.md) (F8, F9)
- **Glossary terms**: [Fill hint](../glossary/hints.md), [Single-line fill hint](../glossary/hints.md), [Multi-line fill hint](../glossary/hints.md)

## Purpose

Optional help that shows which cells line logic already fixes, as an overlay that
never touches board state.

## Rules

- **R1**: For one row or one column ([F3](../../technical/schemata/puzzle-def-fields.md), F4), every valid arrangement
  of that line's runs decides single-line marks: a cell a fill in all arrangements is
  `fill`, a cell in none is `cross`. The union over all lines is the
  [single-line fill hint](../glossary/hints.md) set, written into the entry as `single-fill-hint-cells` (F8) when the
  pack is built ([`CTR-pack`](../../technical/contracts/pack.md) pack layout); no pass derives it during play (G6).
- **R2**: The [multi-line fill hint](../glossary/hints.md) adds one level of propagation: with R1's marks known, every line is
  solved again over only its compatible arrangements; cells forced by that second pass
  that F8 does not already hold are F9 (`multi-fill-hint-cells`, disjoint from F8 by its definition).
  Beyond F9 nothing is added: one level only.
- **R3**: A toggle-on assist overlays its cells with the precomputed mark hints on the
  board: F8 when single-line is on, F8 together with F9 when multi-line is on, without
  writing board marks; the [mark](../glossary/hints.md) a cell holds stays the player's. A toggle-off removes
  the overlays. Nothing is judged per cell while marking ([solve check](../glossary.md) untouched).
- **R4**: An assist applies the moment its toggle is enabled ([configuration.md](../configuration.md)) and reads only
  pack data; the same overlay set holds for every attempt of the puzzle.

## Parameters

- Single-line fill hint, multi-line fill hint, line-level fillable hint options ([configuration.md](../configuration.md) game options; defaults off).
- Overlay colour ([palette](../../aesthetics/palette.md) C8), distinct from the fillable-region
  shade (C9).

## State

| Field | Read / write | When |
|-------|--------------|------|
| Hint preference toggles | read | overlay rendering |
| [`SCH-puzzle-def`](../../technical/schemata/puzzle-def.md) F8/F9 | read | never recomputed |

## Interactions with other features

- **I1**: Enabling an assist during an active attempt is observable so hint-free voids
  ([SCH-preferences](../../technical/schemata/preferences.md) F4-F6; [ADR-0010](../../adr/decisions/0010-hint-preferences.md)); the void logic is not this feature's rule.
- **I2**: The [line-level fillable shade](line-fillable-shade.md) is the later mechanic of the same assist
  class; that spec owns the tap → shade interaction.

## Edge cases

| ID | Situation | Outcome |
|----|-----------|---------|
| X1 | Entry with no forced cells | F8/F9 are empty lists; the overlay shows nothing |
| X2 | A hinted cell is already marked | Overlay only; the player's mark stands |
| X3 | Pack entry missing hint cells at load | CMP-pack rejects the entry |

## Difficulty and configuration effects

- **D1**: Each assist toggle only changes its own overlay ([R3]); no option changes solve rules.

## Experience intent

The player feels hints as trustworthy aids derived from real logic, present only while
enabled, that never corrupt the board.
