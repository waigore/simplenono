# Stories: Controls

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`controls.md`](../controls.md)
- **Spec key**: `IN`
- **Glossary terms**: [Binding](../glossary.md), [Control](../glossary.md)
- **Bindings**: [`controls/bindings.md`](controls/bindings.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| IN.confirm | Accept focused choice | US1.1 |
| IN.cancel | Dismiss without accept | US1.2 |
| IN.back | Previous screen | US1.3 |
| IN.pause | Pause puzzle → settings | US1.4 |
| IN.point | Move keyboard focus | US1.5 |
| IN.activate | Invoke control | US1.6, US1.6b |
| IN.mark-complement | Fill↔cross on cell | US1.7 |
| IN.drag-paint | Paint run with tool | US1.8 |
| Mark tools | Fill/Cross/Clear apply/toggle | US1.6, US1.6b, US1.7, US1.8 |
| F1 | Focus order; unavailable inert | US1.5, US1.9 |
| Bindings | Platform inputs | [`bindings.md`](controls/bindings.md) |

## US1: UI actions

As the Player, I use bound inputs so that marks and navigation match the selected tool.

### US1.1: Confirm

- **Proves**: IN.confirm

```gherkin
Given EX.confirm is showing
When IN.confirm fires
Then the confirm path runs (END.O2)
```

### US1.2: Cancel

- **Proves**: IN.cancel

```gherkin
Given EX.confirm is showing
When IN.cancel fires
Then EX.confirm dismisses with no reset
```

### US1.3: Back

- **Proves**: IN.back

```gherkin
Given UI-puzzle Ready
When IN.back fires via Leave
Then UI-gallery opens
```

### US1.4: Pause

- **Proves**: IN.pause

```gherkin
Given UI-puzzle open
When IN.pause fires
Then UI-settings opens and GS.paused is true
```

### US1.5: Point

- **Proves**: IN.point, F1

```gherkin
Given UI-settings on desktop with focus on C1
When IN.point moves focus downward
Then focus follows C1 then C2 then C3
```

### US1.6: Activate Fill on cell

- **Proves**: IN.activate

```gherkin
Given UI-puzzle Ready, Fill selected, a clear cell focused
When IN.activate fires on that cell
Then the cell becomes fill
```

### US1.6b: Toggle fill off

- **Proves**: IN.activate

```gherkin
Given UI-puzzle Ready, Fill selected, a filled cell focused
When IN.activate fires on that cell
Then the cell becomes clear
```

### US1.7: Mark complement

- **Proves**: IN.mark-complement

```gherkin
Given UI-puzzle Ready, Fill selected, a clear cell
When IN.mark-complement fires on that cell
Then the cell becomes cross
```

### US1.8: Drag-paint

- **Proves**: IN.drag-paint

```gherkin
Given UI-puzzle Ready, Cross selected, a run of clear cells
When IN.drag-paint runs across those cells
Then each cell under the drag is cross with no per-cell toggle
```

### US1.9: Unavailable control

- **Proves**: F1

```gherkin
Given UI-gallery and Reset unavailable for a not-started never-completed puzzle
When the Player activates Reset
Then nothing changes and Reset stays unavailable
```
