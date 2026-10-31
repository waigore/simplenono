# Exception States

Authoring rules: [`.agents/specs/rules/ux/exceptions.md`](../../.agents/specs/rules/ux/exceptions.md).

## Exceptions

| ID | When it appears | Actor sees | Actor can | Blocks the screen | Recovery |
|----|-----------------|------------|-----------|-------------------|----------|
| `EX.confirm` | Gallery reset ([`UI-gallery.C2`](screens/gallery.md)) when ever-completed or in progress | [`copy.reset-title`](screens/gallery.md); Confirm / Cancel | Confirm → [`END.O2`](../design/end-conditions.md); Cancel → dismiss | Yes | Confirm or Cancel returns to gallery Default |

Unused skeleton exceptions (loading, empty, error, interrupt, save-failure, unsupported-input) are omitted until a formalized screen needs them.

## Experience intent

Reset confirm is calm and deliberate — clear consequence, easy Cancel, no alarm styling.
