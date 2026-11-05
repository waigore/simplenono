# ADR-0010: Durable hint-assist preferences

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-11-05
- **Category**: Data storage
- **Supersedes**: None
- **Informed by**: Optional hint assists distinct from clues ([`definition.md`](../../definition/definition.md) scope; [`configuration.md`](../../design/configuration.md) game options). Three toggles on [`UI-settings`](../../ux/screens/settings.md) that persist across sessions ([`SCH-preferences`](../../technical/schemata/preferences.md) F4–F6). Session prefs out of scope in [ADR-0002](0002-user-data-dir.md). Same `user://` + `ConfigFile` pattern as [ADR-0009](0009-orientation-preference.md). Unpinned engine ([ADR-0001](0001-godot-gdscript.md)).

## Context

The player may enable three optional hint assists from settings. Those choices must survive quit and force-quit. [ADR-0002](0002-user-data-dir.md) keeps `user://progress.cfg` for progress only; haptics and mute stay session-only. [ADR-0009](0009-orientation-preference.md) already stores one durable shell preference apart from progress. Nothing stores hint toggles yet.

## Purpose

Where the three durable hint-assist preferences live and who writes them. In scope: the document, keys, defaults, writer, and failure behavior. Out: overlay and shade behaviour, hint-free earn/void rules, and settings chrome.

## Decision

- **One document**: a Godot `ConfigFile` at `user://hint-prefs.cfg`.
- **Shape**: section `hints` with boolean keys `single-line`, `multi-line`, and `line-fillable`.
- **Default**: absent, unreadable, or non-boolean reads as off for that key ([`SCH-preferences`](../../technical/schemata/preferences.md) F4–F6).
- **One writer**: [`CMP-shell`](../../technical/components/shell.md) writes when a hint toggle changes, never at launch. `CMP-pack` does not open it.
- **Failure**: temp file then rename; a failed write leaves the previous document.
- **Apart from progress**: absent from `user://progress.cfg` and from `user://orientation.cfg`.

## Reasoning

1. **Must outlast the app** (definition / UX): a durable `user://` document restores the three choices.
2. **One writer, one purpose** ([ADR-0002](0002-user-data-dir.md)): a separate file keeps progress sole-writer and matches [ADR-0009](0009-orientation-preference.md).
3. **Defaults off**: missing keys are ordinary first launch, not an error.
4. **Cost**: one small extra `user://` file.

## Rejected alternatives

Three options lost. Table: [`rejected.md`](0010-hint-preferences/rejected.md).

## Non-functional requirements

Tables: [`non-functional.md`](0010-hint-preferences/non-functional.md).

### Quality expectations

N/A — see the split file.

### Engineering qualities

N/A — see the split file.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`persistence.md`](../../technical/persistence.md) | D5 / M4 name the file, section, keys, and write point for F4–F6 |
| [`CMP-shell`](../../technical/components/shell.md) | Sole writer; loads F4–F6 at app start; an assist already on at open seeds the attempt ineligible to earn hint-free, and a turn-on during an open attempt voids that attempt's hint-free (O9) |
| [`SCH-preferences`](../../technical/schemata/preferences.md) | F4–F6 are durable booleans defaulting off |

## Validation

| Check | Method | When |
|-------|--------|------|
| Stored toggles restore after relaunch | automated test | before acceptance |
| Missing or unreadable document reads all off | automated test | before acceptance |
| Failed write leaves the previous document | automated test | before acceptance |
| Values never land in `user://progress.cfg` | review rule | before acceptance |
