# Schema: Preferences

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: value object
- **Owner**: [`CMP-shell`](../components/shell.md)
- **Serves**: Haptics, music mute, locked mobile orientation, and three hint assists ([`screens/settings.md`](../../ux/screens/settings.md), [`haptics.md`](../../view/haptics.md) S1, [`configuration.md`](../../design/configuration.md))
- **Informed by**: [`screens/settings.md`](../../ux/screens/settings.md), [`view.md`](../../view/view.md), [`configuration.md`](../../design/configuration.md)
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-gdscript.md), [ADR-0002](../../adr/decisions/0002-user-data-dir.md), [ADR-0009](../../adr/decisions/0009-orientation-preference.md), [ADR-0010](../../adr/decisions/0010-hint-preferences.md)

## Fields

| ID | Field | Type / shape | Required | Notes |
|----|-------|--------------|----------|-------|
| F1 | haptics | Boolean | required | Default on; session only |
| F2 | mute-bgm | Boolean | required | Default off; session only |
| F3 | orientation | Enum: `portrait` or `landscape` | required | Mobile only. Default portrait, then stored ([ADR-0009](../../adr/decisions/0009-orientation-preference.md)) |
| F4 | hint-single-line | Boolean | required | Default off; durable ([ADR-0010](../../adr/decisions/0010-hint-preferences.md)) |
| F5 | hint-multi-line | Boolean | required | Default off; durable |
| F6 | hint-line-fillable | Boolean | required | Default off; durable |

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | F2 mutes the bed and leaves mark ticks and the solve sting audible |
| I2 | F3 holds `portrait` or `landscape`. A missing, unreadable, or other stored value reads as `portrait` |
| I3 | F4–F6 default off. A missing, unreadable, or non-boolean stored value for a key reads as off |
| I4 | Turning any of F4–F6 from off to on while an attempt is open is observable to hint-free consumers |

## Lifecycle

| ID | Phase | Who | What changes |
|----|------|-----|--------------|
| L1 | create | [`CMP-shell`](../components/shell.md) | App start: F1 on, F2 off; F3–F6 from store or defaults |
| L2 | update | [`CMP-shell`](../components/shell.md) | A settings toggle; F3 / F4–F6 store at once ([`persistence.md`](../persistence.md) M3–M4) |
| L3 | destroy | [`CMP-shell`](../components/shell.md) | App quit. F1–F2 gone; F3–F6 stay stored |
| L4 | load | [`CMP-shell`](../components/shell.md) | At app start, reads F3 and F4–F6 before the first screen |

## Relationships

| Related schema | Cardinality | Notes |
|----------------|-------------|-------|
| None — standalone | — | Session flags plus durable orientation and hint assists |

## Diagram

None — session flags and two durable documents.

## Persistence

F1 and F2 last for the app session; [ADR-0002](../../adr/decisions/0002-user-data-dir.md) does not store them. F3 is durable on `user://orientation.cfg` ([ADR-0009](../../adr/decisions/0009-orientation-preference.md); [`persistence.md`](../persistence.md) M3). F4–F6 are durable on `user://hint-prefs.cfg` ([ADR-0010](../../adr/decisions/0010-hint-preferences.md); M4). None enter `user://progress.cfg`.
