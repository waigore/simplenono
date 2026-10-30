# Code review sources

Shared by `review-code` and `audit-code-structure`. Do not copy this precedence into those skills.

Apply, in order. A higher source wins.

1. [`docs/solid.md`](../../../../docs/solid.md) — SOLID, template-owned, every project.
2. [`docs/coding-conventions.md`](../../../../docs/coding-conventions.md) — project rules (`CC-<n>` at `must` or `should`). Diff review also uses the commands run by `Code lint`, `Unit tests`, and `Coverage`.
3. Structure continuity — existing layout, naming, layering, and patterns.

Do not invent principles or convention rules.

**Conventions file:** If the Rules table says `None — SOLID only`, skip convention checks and note that. If it still holds placeholders, skip them and note "conventions not filled in". A rule that contradicts `docs/solid.md` is one `CONV` finding against `docs/coding-conventions.md`. Do not apply that rule.

Do not record a `CONV` or `CONT` finding for a change SOLID requires, or a `CONT` finding for a change a convention requires.

**Implementation code:** source, tests, and build or config that shapes runtime. Exclude `pocs/` unless the caller includes a path under `pocs/` ([PoCs](../../../../docs/pocs.md)). Code promoted out of `pocs/` into the main tree is in scope. Exclude docs, specs, and agent skills or rules.
