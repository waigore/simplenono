# Stories: Exceptions

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`exceptions.md`](../exceptions.md)
- **Spec key**: `EX`
- **Glossary terms**: [Player](../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| EX.confirm | Reset confirm show + recover | US1.1, US1.2, US1.3 |

## US1: Reset confirm

As the Player, I confirm or cancel gallery reset so that wipes stay deliberate.

### US1.1: Confirm appears

- **Proves**: EX.confirm

```gherkin
Given UI-gallery and Reset is available for puzzle P
When the Player activates UI-gallery.C2
Then EX.confirm shows copy.reset-title with Confirm and Cancel
And it blocks the gallery screen
```

### US1.2: Confirm recovers

- **Proves**: EX.confirm

```gherkin
Given EX.confirm is showing for P
When the Player confirms
Then END.O2 applies for P
And the Player returns to UI-gallery Default
```

### US1.3: Cancel recovers

- **Proves**: EX.confirm

```gherkin
Given EX.confirm is showing for P
When the Player cancels
Then P's progress is unchanged
And the Player returns to UI-gallery Default
```
