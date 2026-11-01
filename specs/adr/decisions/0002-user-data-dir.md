# ADR-0002: User data directory

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-11-01
- **Category**: Data storage
- **Supersedes**: None
- **Informed by**: Offline play and persisted progress in [`definition.md`](../../definition/definition.md). Platforms in that definition. [ADR-0001](0001-godot-gdscript.md), which leaves save location and format unset. Progress fields in [`progression.md`](../../design/progression.md).

## Context

Progress must persist on device, with no network. ADR-0001 leaves the save location and format unset. Godot's `user://` prefix maps to a per-user data directory on desktop and to private app storage on iOS and Android.

## Purpose

Where durable progress is stored, and which Godot facility writes it. In scope: the writable root and the progress document. Out of scope: shipped puzzle definitions, catalog and asset roots, and session preferences.

## Decision

Durable progress is one Godot `ConfigFile` at `user://progress.cfg`. Game code opens it only through `user://`. `application/config/use_custom_user_dir` is enabled, and the folder name is the project application name. Desktop lands under `%APPDATA%`, `~/Library/Application Support`, or `~/.local/share`. iOS and Android use the app's private storage. The pack component is the only writer. A failed write leaves the previous file.

## Reasoning

1. Offline local pack. `user://` stays on the device.
2. One prefix covers desktop user-data directories and mobile app storage.
3. `ConfigFile` ships with Godot and holds the 200 progress records.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Absolute OS paths | They skip the prefix and do not match mobile app storage |
| `res://` for progress | The exported project is read-only |
| A Godot resource file for progress | It couples the save to engine resource types |
| A third-party database | The record set is one local file, and no library ADR exists |

## Non-functional requirements

Tables: [`non-functional.md`](0002-user-data-dir/non-functional.md).

### Quality expectations

`frame-time` and `hitch-bound` stay as set. The other categories are still unset.

### Engineering qualities

`user://` and `ConfigFile` ship with Godot. The five definition platforms are in scope.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`persistence.md`](../../technical/persistence.md) | Progress is `user://progress.cfg`, written only by the pack, and a failed write leaves the previous file |
| [`CMP-pack`](../../technical/components/pack.md) | Sole writer of that file |
| [`SCH-progress`](../../technical/schemata/progress.md) | Durable fields live in that file |

## Validation

| Check | Method | When |
|-------|--------|------|
| Progress paths use `user://` only | review rule | before acceptance |
| Custom user dir is enabled | review rule | before acceptance |
| A failed write leaves the previous file | automated test | before acceptance |
