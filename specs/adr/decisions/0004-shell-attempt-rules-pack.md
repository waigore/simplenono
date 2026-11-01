# ADR-0004: Shell, attempt, rules, and pack

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-11-01
- **Category**: Game architecture
- **Supersedes**: None
- **Informed by**: [ADR-0001](0001-godot-gdscript.md); local pack and free-order play ([`definition.md`](../../definition/definition.md), [`design.md`](../../design/design.md)); gallery / puzzle / result / settings ([`ux.md`](../../ux/ux.md)); [`technical.md`](../../technical/technical.md), [`layers.md`](../../technical/layers.md), [`modules.md`](../../technical/modules.md).

## Context

Engine, save location, and asset roots are set. Technical design already names presentation, play, and records components, but the ADR hub left game architecture unset.

## Purpose

How the running game is structured: layers, components, and who may call whom. In scope: L1–L3, the four components, and contract-only peer calls. Out of scope: save format ([ADR-0002](0002-user-data-dir.md)), asset roots ([ADR-0003](0003-catalog-asset-roots.md)), scene file layout detail.

## Decision

- **Layers**: L1 Presentation; L2 Play; L3 Records. A layer may depend only on a higher id or itself; L3 calls neither L1 nor L2.
- **Components**: `CMP-shell` (L1) shows gallery, puzzle, result, and settings, and resolves the asset manifest. `CMP-attempt` (L2) owns the open puzzle, marks, and timer. `CMP-rules` (L2) answers solve check and clue-line cues with no writable play state. `CMP-pack` (L3) owns definitions and progress. Pack does not call upward.
- **Contracts**: Shell ↔ attempt via `CTR-attempt`; shell → pack and attempt → pack via `CTR-pack`; attempt → rules via `CTR-rules`.

## Reasoning

1. Match the formalized technical design so ADRs and technical stay one shape.
2. Keep records free of UI and mark logic for offline durable progress ([ADR-0002](0002-user-data-dir.md)).
3. Pure rules keep solve and line cues testable without the shell.
4. One shell owns presentation and manifest resolve ([ADR-0003](0003-catalog-asset-roots.md)).

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Monolithic scene script owning marks and progress | Mixes L1–L3; hard to test rules and saves separately |
| Pack calling shell or attempt | Breaks L3 upward ban and progress ownership |
| Rules owning marks | Solve checks would mutate play state |

## Non-functional requirements

Tables: [`non-functional.md`](0004-shell-attempt-rules-pack/non-functional.md).

### Quality expectations

Structure only; does not change quality targets.

### Engineering qualities

No new licensed dependency. Boundaries improve unit tests for rules and pack.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`layers.md`](../../technical/layers.md) | Keep L1–L3 and D1–D3 as in Decision |
| [`modules.md`](../../technical/modules.md) | Keep M1–M3 and B1–B4 matching those layers |
| [`components/`](../../technical/components/) | Shell, attempt, rules, pack only for those roles; pack does not call upward |
| [`technical.md`](../../technical/technical.md) | Overview call graph matches Decision |

## Validation

| Check | Method | When |
|-------|--------|------|
| Layer and module maps match this ADR | review rule | before acceptance |
| No L3 → L1/L2 calls in code | review rule | every release |
| Rules stay free of writable play state | unit tests on `CTR-rules` | every build once tests exist |
