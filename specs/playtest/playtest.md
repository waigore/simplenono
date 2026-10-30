# Playtesting

Authoring rules: [`.agents/specs/rules/playtest/playtest.md`](../../.agents/specs/rules/playtest/playtest.md).

## Purpose

AI-agent playtesting proves the running build against game design and UX. It is not a unit or integration test plan (see `specs/technical/verification.md`). View stories are out of scope.

## Levels

| Level | Proves | Cites |
|-------|--------|-------|
| Design | Game behaves and feels as designed | Design story / element IDs |
| UX | Actors can operate the interface as specified | UX story / journey IDs |

## Coverage

- **Mode**: <!-- fill in: full | critical-only -->
- **Critical IDs**: see [`coverage.md`](coverage.md)

## Gate

Required at `status:pending-acceptance` (`accept-project-issue`) when the issue's deliverables change playable behavior (game or code). Not required for spec-only, docs-only, or other non-playable deliverables.

## Evidence

Root: [`docs/playtest/evidence/`](../../docs/playtest/evidence/). Each required run records story IDs, pass/fail, notes, and logs. Screenshots come from a graphical re-run of the same build and are required before acceptance, unless the protocol says none. A headless run may omit them without a defect. Schema: [`evidence.md`](evidence.md).

## Architecture constraints

| Kind | Capability | Playtest need |
|------|------------|---------------|
| Must | Debug UI | Agent can inspect and control play state while running protocols |
| Must | Telemetry events | Agent can correlate observations to story IDs and outcomes |
| Situational | Seed, replay, state dump — see [`tools.md`](tools.md) | When a protocol requires them |

ADRs and technical design (including verification seams) must satisfy Must rows. Situational rows apply only when a protocol needs them. Detail: [`tools.md`](tools.md).

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`ids.md`](ids.md), [`traceability.md`](traceability.md), [`coverage.md`](coverage.md), [`story-rows.md`](story-rows.md), [`tools.md`](tools.md), [`procedures.md`](procedures.md), [`evidence.md`](evidence.md).

- **Design protocols**: None yet — copy [`design/_template.md`](design/_template.md)
- **UX protocols**: None yet — copy [`ux/_template.md`](ux/_template.md)
