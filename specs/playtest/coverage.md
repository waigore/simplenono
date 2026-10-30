# Playtest coverage

Authoring rules: [`.agents/specs/rules/playtest/coverage.md`](../../.agents/specs/rules/playtest/coverage.md).

## Mode

Declared on [`playtest.md`](playtest.md): `full` or `critical-only`.

| Mode | Playtest set |
|------|----------------|
| `full` | Every design story and every UX journey (then intersected with issue scope in [`procedures.md`](procedures.md)) |
| `critical-only` | Only the Critical IDs table below (then intersected with issue scope) |

View stories are never in the set. Prefer `full` for complex projects; `critical-only` for smaller ones with an explicit critical set.

## Critical IDs

| ID | Upstream story / journey ID | Why critical |
|----|-----------------------------|--------------|
| <!-- fill in: C1… when critical-only; or one row — / — / None — mode is full --> | <!-- fill in --> | <!-- fill in --> |

## Issue mapping

A required acceptance playtest runs protocols for the intersection of this coverage set and the design/UX IDs the issue's playable deliverables can affect. See [`procedures.md`](procedures.md).

Delivery ownership (which epic/task owns a story, or `none` with a durable reason) lives in [`story-rows.md`](story-rows.md) — not in this file.
