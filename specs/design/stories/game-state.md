# Stories: Game state

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state.md`](../game-state.md)
- **Spec key**: `GS`
- **Glossary terms**: [Ever completed](../glossary.md), [Attempt status](../glossary.md), [Cross](../glossary.md), [Line error](../glossary.md), [Solve check](../glossary.md), [Thumbnail](../glossary.md)
- **Fields**: [`game-state/fields.md`](game-state/fields.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| is-solved | Fills only | PS1.1 |
| completion-rate | Count ÷ 200 | PS1.2 |
| row/col-error | Contradiction | PS1.3, PS1.3b |
| clue-satisfied | Exact runs | PS1.4, PS1.4b |
| gallery-thumbnail | After ever-completed | PS1.5 |
| V1, V2, V5, V6 | Invariants | PS1.1, PS1.5, PS1.6 |
| V3, V4 | Invariants | [`fields.md`](game-state/fields.md) |
| H1, H2 | Hidden / knowable state | PS1.5, PS1.8 |
| Q1 | Deterministic | PS1.7 |
| Fields | Init / reset / invariants | [`fields.md`](game-state/fields.md) |

## PS1: Derived and invariants

As a player, I rely on derived state so that solve and gallery progress stay consistent.

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

### PS1.3: Line error off

- **Proves**: row-error, col-error

```gherkin
Given a row incomplete but still possible
When line errors are derived
Then GS.row-error for that row is false
```

### PS1.3b: Line error on

- **Proves**: row-error, col-error

```gherkin
Given fills contradict a row's clues
When line errors are derived
Then GS.row-error for that row is true
```

### PS1.4: Clue satisfied

- **Proves**: clue-satisfied

```gherkin
Given fills exactly match a line's runs
When clue-satisfied is derived
Then GS.clue-satisfied for that line is true
```

### PS1.4b: Clue unsatisfied

- **Proves**: clue-satisfied

```gherkin
Given fills no longer match a line's runs
When clue-satisfied is derived
Then GS.clue-satisfied for that line is false
```

### PS1.5: Thumbnail knowability

- **Proves**: gallery-thumbnail, H1, H2, V1, V6

```gherkin
Given ever-completed is false and P's stored generated picture is not knowable
When ever-completed becomes true with personal-best 30
Then the player can know P's gallery thumbnail
And the player can know ever-completed, attempt-status, marks, elapsed, paused, personal-best, completion-rate, line errors, clue-satisfied
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

### PS1.8: Picture knowledge

- **Proves**: H1

```gherkin
Given P is not ever-completed and P's fill set is not knowable
When the player first solves P
Then the player can know P's stored pixel picture from that solve on
And P's stored generated picture is knowable in the gallery once ever-completed
```
