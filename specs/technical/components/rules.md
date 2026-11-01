# Component: Rules

Authoring rules: [`.agents/specs/rules/technical/components.md`](../../../.agents/specs/rules/technical/components.md).

- **Layer**: [L2](../layers.md) Play
- **Module**: [M2](../modules.md) play
- **Serves**: Whole-puzzle solve check, line error, and clue satisfaction ([`game-state.md`](../../design/game-state.md))
- **Informed by**: [`entities/cell.md`](../../design/entities/cell.md), [`entities/clue.md`](../../design/entities/clue.md), [`loops/solve.md`](../../design/loops/solve.md)
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-gdscript.md)

## Responsibilities

| ID | Responsibility |
|----|----------------|
| R1 | Report whether the player's fill set equals the solution fill set. Crosses are ignored |
| R2 | Report error and satisfied for each clue line from that line's run lengths and the current fills |
| R3 | Return still-clear cells on an empty clue line for auto-cross |
| R4 | Keep no stored clue-line identity |

## Communication

| ID | Peer | Direction | Via contract | Notes |
|----|------|-----------|--------------|-------|
| C1 | [`CMP-attempt`](attempt.md) | listens | [`CTR-rules`](../contracts/rules.md) | The attempt calls. Rules return values and write nothing |

## Owns / mutates

| Schema or state | Access |
|-----------------|--------|
| [`SCH-line-status`](../schemata/line-status.md) | creates for a check, then discards |

## Diagram

None — one peer.

## Failure / concurrency / persistence

N/A — pure checks. No durable state.
