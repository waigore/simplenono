# ADR-0001: Godot with GDScript

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-11-01
- **Category**: Engine
- **Supersedes**: None
- **Informed by**: Engine, supported platforms, and the offline constraint in [`definition.md`](../../definition/definition.md). Calm tactile grid and Snappy solve in [`vision.md`](../../vision.md). Performance targets `frame-time` and `hitch-bound` in [`quality.md`](../../definition/quality.md).

## Context

The definition names Godot for one 2D, UI-led project exported to Windows, macOS, Linux, iOS, and Android. Core play stays offline after install. No prior decision fixed the language or a release pin.

## Purpose

Which language and release this Godot project uses. In scope: the engine runtime and the game language. Out of scope: save format, asset roots, frameworks, and module layout.

## Decision

One Godot project. Game code is GDScript. The release is unpinned: any Godot release that exports that project to the five platforms in the definition. Presentation stays 2D and UI-led. Core play, puzzle status, in-progress marks, and personal bests do not require a network. C# is not the game language. This decision does not choose storage, integrations, or code structure.

## Reasoning

1. Shared desktop and mobile reach. One project exports to every platform in the definition.
2. Snappy solve. A 2D UI project is how grid paint stays within `frame-time` and `hitch-bound`.
3. Offline local pack. The project does not require a network for core play.
4. Language. The product owner chose GDScript. No upstream spec requires C#.
5. Release. The product owner left the release unpinned. No upstream spec names a patch.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| A different engine | None — the engine is set in the definition |
| C# | The product owner chose GDScript. No upstream spec requires C# |
| A pinned release | The product owner chose any release. No upstream spec names a patch |

## Non-functional requirements

Tables: [`non-functional.md`](0001-godot-gdscript/non-functional.md).

### Quality expectations

Performance is the only category this decision affects (`frame-time`, `hitch-bound`). The other quality categories are still unset.

### Engineering qualities

Godot is MIT-licensed. GDScript ships with it. The five definition platforms and offline play stay in scope. Save location and playtest sinks stay later decisions.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| — | None |

## Validation

| Check | Method | When |
|-------|--------|------|
| Grid paint frame time | Cites `frame-time` | before acceptance |
| Grid paint hitch length | Cites `hitch-bound` | before acceptance |
| Export set | review rule: one project exports to the five definition platforms | before acceptance |
| Offline core play | review rule: core play does not require a network | before acceptance |
