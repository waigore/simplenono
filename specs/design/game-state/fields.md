# Game state fields

Authoring rules: [`.agents/specs/rules/design/game-state.md`](../../../.agents/specs/rules/design/game-state.md).

Parent: [`../game-state.md`](../game-state.md).

| Field | Scope | Meaning | Initial | Changed by | Invariants |
|-------|-------|---------|---------|------------|------------|
| `GS.selected-puzzle` | Session | Open puzzle, or none | none | Open / leave | — |
| `GS.marks-allowed` | Stage | Marks may change | false in get-set-ready | Ready → true | false ⇒ no mark changes |
| `GS.paused` | Stage | Puzzle on hold; timer frozen; marks blocked | false | Pause on; Back/leave/solve off | true ⇒ no tick; no marks |
| `GS.cell-marks` | Stage; Persistent if in progress | clear / fill / [cross](../glossary.md) | all clear or restored | Marks, solve, reset, restore | One of three |
| `GS.ever-completed` | Persistent | ≥1 successful solve | false | First [`END.W1`](../end-conditions.md); reset clears | Sticky until reset |
| `GS.attempt-status` | Persistent | not started or in progress | not started | First mark (incl. auto-cross) → in progress; solve/reset → not started | Orthogonal to ever-completed |
| `GS.solve-elapsed` | Stage; Persistent if in progress | Elapsed this attempt | 0; restored on reopen | Ticks after ready if not paused; clear on solve/reset | ≥ 0; frozen while paused |
| `GS.personal-best` | Persistent | Shortest successful time | none | Shorter solve; cleared on gallery reset | Never increases while set |
| `GS.solution` | Stage | Hidden correct fills | Loaded with puzzle | Never by player | Fixed per puzzle |
