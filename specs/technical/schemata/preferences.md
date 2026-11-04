# Schema: Preferences

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: value object
- **Owner**: [`CMP-shell`](../components/shell.md)
- **Serves**: Haptics, music mute, and the locked mobile orientation ([`screens/settings.md`](../../ux/screens/settings.md), [`haptics.md`](../../view/haptics.md) S1)
- **Informed by**: [`screens/settings.md`](../../ux/screens/settings.md), [`view.md`](../../view/view.md) platform implications
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-gdscript.md), [ADR-0002](../../adr/decisions/0002-user-data-dir.md), [ADR-0009](../../adr/decisions/0009-orientation-preference.md)

## Fields

| ID | Field | Type / shape | Required | Notes |
|----|-------|--------------|----------|-------|
| F1 | haptics | Boolean | required | Default on |
| F2 | mute-bgm | Boolean | required | Default off |
| F3 | orientation | Enum: `portrait` or `landscape` | required | Mobile only. Default portrait, then the stored choice ([ADR-0009](../../adr/decisions/0009-orientation-preference.md)) |

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | F2 mutes the bed and leaves mark ticks and the solve sting audible |
| I2 | F3 holds `portrait` or `landscape`. A missing, unreadable, or other stored value reads as `portrait` |

## Lifecycle

| ID | Phase | Who | What changes |
|----|------|-----|--------------|
| L1 | create | [`CMP-shell`](../components/shell.md) | App start, at the defaults: F1 on, F2 off, F3 portrait when nothing is stored |
| L2 | update | [`CMP-shell`](../components/shell.md) | A settings toggle; a changed F3 is stored at once ([`persistence.md`](../persistence.md) M3) |
| L3 | destroy | [`CMP-shell`](../components/shell.md) | App quit. F1 and F2 are gone; F3 stays stored |
| L4 | load | [`CMP-shell`](../components/shell.md) | At app start, reads the stored F3 before the first screen shows |

## Relationships

| Related schema | Cardinality | Notes |
|----------------|-------------|-------|
| None — standalone | — | Two session flags and one durable value |

## Diagram

None — two session flags and one durable value.

## Persistence

F1 and F2 last for the app session; [ADR-0002](../../adr/decisions/0002-user-data-dir.md) does not store them. F3 is durable on its own `user://orientation.cfg` ([ADR-0009](../../adr/decisions/0009-orientation-preference.md); [`persistence.md`](../persistence.md) M3) and is absent from `user://progress.cfg`.
