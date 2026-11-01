# Design Traceability

Authoring rules: [`.agents/specs/rules/design/traceability.md`](../../.agents/specs/rules/design/traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Calm tactile grid | vision | [`entities/cell.md`](entities/cell.md), [`loops/solve.md`](loops/solve.md), [`experience.md`](experience.md) |
| Snappy solve | vision | [`loops/solve.md`](loops/solve.md), [`experience.md`](experience.md), [`configuration.md`](configuration.md) |
| Cool clinical look | vision | [`experience.md`](experience.md), [`world.md`](world.md) |
| Local pack; free-order; persist completion / PB / marks | definition | [`progression.md`](progression.md), [`entities/puzzle.md`](entities/puzzle.md), [`game-state.md`](game-state.md) |
| Desktop and mobile play | definition | [`design.md`](design.md) platform implications; [`experience.md`](experience.md) |
| Goal: fill from clues; win on match; no lose | definition | [`loops/solve.md`](loops/solve.md), [`end-conditions.md`](end-conditions.md), [`entities/clue.md`](entities/clue.md) |
| Free-order progression; sticky ever-completed; PB score | definition | [`progression.md`](progression.md), [`end-conditions.md`](end-conditions.md) |

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Core loop and mechanics | [`loops/`](loops/), [`features/`](features/) | Applies (`loops/solve.md`) |
| Characters | [`characters/`](characters/) | N/A — no avatar or NPCs |
| Entities (items, objects, hazards) | [`entities/`](entities/) | Applies (`entities/puzzle.md`, `entities/cell.md`, `entities/clue.md`) |
| World and narrative | [`world.md`](world.md) | Applies (no diegetic story; clinical abstract space) |
| Flows and transitions | [`flows/`](flows/) | N/A — session arc in [`experience.md`](experience.md); screens/journeys under UX |
| Stages and scenes | [`stages/`](stages/) | N/A — no spatial stages |
| Game state | [`game-state.md`](game-state.md), [`game-state/fields.md`](game-state/fields.md) | Applies |
| Configuration | [`configuration.md`](configuration.md) | Applies (Standard mode; tunables `CFG.GET_SET_READY_MS`, `CFG.MORPH_STAGE_MS`) |
| Demo mode | [`demo.md`](demo.md) | N/A — not offered |
| Difficulty settings | [`difficulty.md`](difficulty.md) | Applies (fixed; pack content sets challenge) |
| Scenarios | [`scenarios/`](scenarios/) | N/A — no authored scenario scripts |
| Progress management | [`progression.md`](progression.md) | Applies |
| Sub-games | [`sub-games/`](sub-games/) | N/A — none |
| Win and loss conditions | [`end-conditions.md`](end-conditions.md) | Applies |
| Economy and resources | [`features/`](features/) | N/A — no economy |
| Opponent and NPC behavior | [`characters/`](characters/), [`features/`](features/) | N/A — no opponents or NPCs |
| Experience and feel | [`experience.md`](experience.md) | Applies |
