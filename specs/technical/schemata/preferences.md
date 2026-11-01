# Schema: Preferences

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: value object
- **Owner**: [`CMP-shell`](../components/shell.md)
- **Serves**: Haptics and music mute ([`screens/settings.md`](../../ux/screens/settings.md), [`haptics.md`](../../view/haptics.md) S1)
- **Informed by**: [`screens/settings.md`](../../ux/screens/settings.md)
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-gdscript.md)

## Fields

| ID | Field | Type / shape | Required | Notes |
|----|-------|--------------|----------|-------|
| F1 | haptics | Boolean | required | Default on |
| F2 | mute-bgm | Boolean | required | Default off |

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | F2 mutes the bed and leaves the mark tick and the solve sting audible |

## Lifecycle

| ID | Phase | Who | What changes |
|----|-------|-----|--------------|
| L1 | create | [`CMP-shell`](../components/shell.md) | App start, at the defaults |
| L2 | update | [`CMP-shell`](../components/shell.md) | A settings toggle |
| L3 | destroy | [`CMP-shell`](../components/shell.md) | App quit |

## Relationships

| Related schema | Cardinality | Notes |
|----------------|-------------|-------|
| None — session flags | — | Standalone |

## Diagram

None — two flags.

## Persistence

N/A — the values last for the app session. [ADR-0002](../../adr/decisions/0002-user-data-dir.md) does not store them.
