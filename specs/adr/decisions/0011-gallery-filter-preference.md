# ADR-0011: Durable gallery incomplete-only filter preference

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-11-06
- **Category**: Data storage
- **Supersedes**: None
- **Informed by**: A gallery chrome toggle that narrows the pack to not-ever-completed puzzles ([`screens/gallery.md`](../../ux/screens/gallery.md) C5; feedback #694 locked shape). The choice must survive quit ([`SCH-preferences`](../../technical/schemata/preferences.md) F7). Session prefs out of scope in [ADR-0002](0002-user-data-dir.md). Same `user://` + `ConfigFile` pattern as [ADR-0009](0009-orientation-preference.md) and [ADR-0010](0010-hint-preferences.md). Unpinned engine ([ADR-0001](0001-godot-gdscript.md)).

## Context

The gallery offers a filter that, when on, shows only puzzles that are not ever-completed. The player's choice must survive quit and force-quit. [ADR-0002](0002-user-data-dir.md) keeps `user://progress.cfg` for progress only. [ADR-0009](0009-orientation-preference.md) stores the mobile orientation and [ADR-0010](0010-hint-preferences.md) stores the hint assists, each in its own document. Nothing stores the gallery filter yet.

## Purpose

Where the durable gallery incomplete-only filter lives and who writes it. In scope: the document, section, key, default, writer, and failure behavior. Out: the filter's rendering, the visible-set rule, and the completion rate.

## Decision

- **One document**: a Godot `ConfigFile` at `user://gallery-prefs.cfg`.
- **Shape**: the boolean key `incomplete-only` under the section `gallery`.
- **Default**: absent, unreadable, or non-boolean reads as off ([`SCH-preferences`](../../technical/schemata/preferences.md) F7).
- **One writer**: [`CMP-shell`](../../technical/components/shell.md) writes when the gallery filter changes, never at launch. `CMP-pack` does not open it.
- **Failure**: temp file then rename; a failed write leaves the previous document.
- **Apart from progress**: absent from `user://progress.cfg`, `user://orientation.cfg`, and `user://hint-prefs.cfg`.

## Reasoning

1. **Must outlast the app** (feedback #694): a durable `user://` document restores the choice.
2. **One writer, one purpose** ([ADR-0002](0002-user-data-dir.md)): a separate file keeps progress sole-writer and matches [ADR-0009](0009-orientation-preference.md) and [ADR-0010](0010-hint-preferences.md).
3. **Default off**: a missing key is ordinary first launch, not an error, and the gallery opens on the full pack.
4. **Cost**: one small extra `user://` file.

## Rejected alternatives

Three options lost. Table: [`rejected.md`](0011-gallery-filter-preference/rejected.md).

## Non-functional requirements

Tables: [`non-functional.md`](0011-gallery-filter-preference/non-functional.md).

### Quality expectations

N/A — see the split file.

### Engineering qualities

N/A — see the split file.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`persistence.md`](../../technical/persistence.md) | D6 / M5 name the file, section, key, and write point for F7 |
| [`CMP-shell`](../../technical/components/shell.md) | R9: sole writer; loads F7 at app start and presents it to the gallery |
| [`SCH-preferences`](../../technical/schemata/preferences.md) | F7 is a durable boolean defaulting off; I5 keeps it out of progress and the completion rate |

## Validation

| Check | Method | When |
|-------|--------|------|
| Stored filter restores after relaunch | automated test | before acceptance |
| Missing or unreadable document reads off | automated test | before acceptance |
| Failed write leaves the previous document | automated test | before acceptance |
| Values never land in `user://progress.cfg` | review rule | before acceptance |
