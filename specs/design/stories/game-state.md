# Stories: Game state

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state.md`](../game-state.md)
- **Spec key**: `GS`
- **Glossary terms**: [Ever completed](../glossary.md), [Attempt status](../glossary.md), [Cross](../glossary.md), [Fill island](../glossary.md), [Line error](../glossary.md)
- **Fields**: [`game-state/fields.md`](game-state/fields.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| is-solved | Fills only | PS1.1 |
| completion-rate | Count ÷ 200 | PS1.2 |
| row/col-error | Contradiction | PS1.3 |
| clue-num-matched | Island matches its number | PS1.4, PS1.4b |
| clue-satisfied | All numbers matched | PS1.4, PS1.4b |
| gallery-thumbnail | After ever-completed | PS1.5 |
| V1, V2, V5, V6 | Invariants | PS1.1, PS1.5, PS1.6 |
| V3, V4 | Invariants | [`fields.md`](game-state/fields.md) |
| H1, H2 | Hidden / knowable state | PS1.5 |
| Q1 | Deterministic | PS1.7 |
| Fields | Init / reset / invariants | [`fields.md`](game-state/fields.md) |

## PS1: Derived and invariants

As a player, I rely on derived state so solve and gallery progress stay consistent.

### PS1.1: Solve ignores crosses

- **Proves**: is-solved, V5

```gherkin
Given fills match the solution and one other cell is cross
When solve check runs
Then GS.is-solved is true
And each cell-mark is clear, fill, or cross
```

### PS1.2: Completion rate

- **Proves**: completion-rate

```gherkin
Given 50 of 200 ever-completed
When completion-rate is derived
Then GS.completion-rate is 0.25
```

### PS1.3: Line error follows the fills

- **Proves**: row-error, col-error

```gherkin
Given a row incomplete but still possible
When line errors are derived
Then GS.row-error for that row is false
And a row whose fills contradict its clues has GS.row-error true
```

### PS1.4: Clue satisfied and each number matched

- **Proves**: clue-num-matched, clue-satisfied

```gherkin
Given fills exactly match a line's runs
When both values are derived
Then GS.clue-satisfied for that line is true
And GS.clue-num-matched is true for each of its numbers
```

### PS1.4b: Un-dimming after a mark, board-wide

- **Proves**: clue-num-matched, clue-satisfied

```gherkin
Given one line's first number is matched and another line's runs are exactly filled
When a mark grows that fill island past its number
Then the whole board re-evaluates: that number is no longer matched
And the other line still satisfies
```

### PS1.5: Knowledge after a first solve

- **Proves**: gallery-thumbnail, H1, H2, V1, V6

```gherkin
Given P is not ever-completed and its fill set and generated picture are not knowable
When the player first solves P with personal-best 30
Then the player can know its stored pixel picture from that solve on
And the player can know ever-completed, attempt-status, marks, elapsed, paused, personal-best, completion-rate, line errors, clue-satisfied, clue-num-matched
And the gallery thumbnail is knowable once ever-completed
And personal-best exists
```

### PS1.6: In progress needs a mark

- **Proves**: V2

```gherkin
Given attempt-status is in progress
When invariants are checked
Then at least one cell is fill or cross
```

### PS1.7: Determinism

- **Proves**: Q1

```gherkin
Given identical pack data and mark sequences on P
When both attempts run
Then cell-marks, is-solved, and end outcomes match
```
