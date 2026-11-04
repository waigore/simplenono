# ADR-0009: Durable mobile orientation preference

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-11-04
- **Category**: Data storage
- **Supersedes**: None
- **Informed by**: A locked mobile orientation, portrait on a cold launch, chosen with [`UI-settings`](../../ux/screens/settings.md) C4 ([`view.md`](../../view/view.md) platform implications). Session preferences out of scope in [ADR-0002](0002-user-data-dir.md). [`CMP-shell`](../../technical/components/shell.md) R5/R7 and [`SCH-preferences`](../../technical/schemata/preferences.md). Unpinned engine ([ADR-0001](0001-godot-gdscript.md)).

## Context

The player picks portrait or landscape on a phone, the screen stays locked to it, and the choice survives a force-quit. [ADR-0002](0002-user-data-dir.md) makes `user://progress.cfg` the progress document, `CMP-pack` its sole writer, and leaves session preferences out of scope; haptics and music mute are session-only. Nothing stores an orientation today, so a relaunch forgets it.

## Purpose

Where the durable orientation preference lives and who writes it. In scope: the document, key, default, writer, and failure behavior. Out: the progress document ([ADR-0002](0002-user-data-dir.md)), the session flags, the control's rendering, and the platform lock.

## Decision

- **One document**: a Godot `ConfigFile` at `user://orientation.cfg`.
- **Shape**: the key `orientation` under the section `display`, holding `portrait` or `landscape`.
- **Default**: absent, unreadable, or any other value reads as `portrait`, the [`SCH-preferences`](../../technical/schemata/preferences.md) F3 default, so a first launch always opens portrait.
- **One writer**: [`CMP-shell`](../../technical/components/shell.md) writes the file when the orientation control changes, never at launch. `CMP-pack` does not open it.
- **Failure**: a write goes to a temp file and is renamed onto the target, so a failed write leaves the previous document.
- **Apart from progress**: the value is absent from `user://progress.cfg` ([ADR-0002](0002-user-data-dir.md), `CMP-pack` sole writer).

## Reasoning

1. **The choice must outlast the app** ([`view.md`](../../view/view.md)): a durable `user://` document restores it, where a session flag would lose it on quit.
2. **One writer, one purpose** ([ADR-0002](0002-user-data-dir.md)): a separate file keeps the progress document out of scope changes and keeps its writer single.
3. **A default, not an error** ([`SCH-preferences`](../../technical/schemata/preferences.md) F3): a missing file is the ordinary first launch, so it reads as portrait.
4. **Cost**: one more small `user://` file.

## Rejected alternatives

Four options lost. Table: [`rejected.md`](0009-orientation-preference/rejected.md).

## Non-functional requirements

Tables: [`non-functional.md`](0009-orientation-preference/non-functional.md).

### Quality expectations

N/A — see the split file.

### Engineering qualities

N/A — see the split file.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`persistence.md`](../../technical/persistence.md) | D4 holds F3 as durable, and M3 names the file, section, key, and write point |
| [`CMP-shell`](../../technical/components/shell.md) | R7 applies the stored value at app start and is the sole writer |
| [`SCH-preferences`](../../technical/schemata/preferences.md) | F3 is `portrait` or `landscape`, defaults to portrait, and is durable |

## Validation

| Check | Method | When |
|-------|--------|------|
| A stored choice is restored and locked after a relaunch | automated test (`game/test/test_orientation_lock.gd`) | before acceptance |
| A missing, unreadable, or unknown document reads as portrait | automated test | before acceptance |
| A failed write leaves the previous document | automated test | before acceptance |
| The value never lands in `user://progress.cfg` | review rule | before acceptance |
