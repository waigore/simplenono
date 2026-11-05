# Technical requirement notes

Raw notes until a technical capture run consumes them. Not specs.

- single-line and multi-line fill hint cells should be pre-calculated and stored along with the puzzle metadata; one-off for all puzzles; part of the contract for new puzzles. — target: `specs/technical/schemata/puzzle-def.md` / `specs/technical/contracts/pack.md`
- hint toggles persisted (preferences). — target: `specs/technical/schemata/preferences.md` / `specs/technical/persistence.md`
- hint-free status persisted per puzzle; cleared when any hint enabled during an active puzzle; re-earned on a later clean solve; cleared on gallery reset. — target: `specs/technical/schemata/` / progress schema
