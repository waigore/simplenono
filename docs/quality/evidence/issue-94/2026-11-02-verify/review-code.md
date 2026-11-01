# Code review — issue #94

## Code review: Pass

**Target:** PR #194 (`9d6ffb7`), PR #199 (`52e8275`), PR #213 (`48d2b58`) code diffs, reviewed at
`48d2b58`. Sources: [`docs/solid.md`](../../../../docs/solid.md),
[`docs/coding-conventions.md`](../../../../docs/coding-conventions.md).

### Findings

- `[CONT]` `suggestion` — `game/presentation/gallery.gd:28,88` duplicates the pack size (`PACK_SIZE := 200`, also owned by `ProgressRules.PACK_SIZE`) and reconstructs `{n}` by `roundi(rate × 200)`. Exposing the ever-completed count from `Pack`/`ProgressRules` would keep one source and stop the screen from re-deriving a pack fact.
- `[CONT]` `suggestion` — `game/presentation/gallery.gd:134-156`: `_rebuild()` recreates/re-`setup()`s every one of the 200 tiles and re-queries the picture provider per entry on every `refresh()` (launch, leave, reset). Reusing unchanged tiles would also shrink the single-frame cost that the blocked `frame-time` row currently cannot observe.
- `[CONT]` `suggestion` — `game/presentation/gallery_tile.gd:128,143`: the tile's `THUMB_MIN_HEIGHT + 56.0` magic and the fixed `THUMB_MIN_HEIGHT` are the only place the thumbnail size is decided, so the mockup's square picture region is not expressed anywhere; a named aspect helper would make the intended shape explicit (see the UI finding in [`rationale.md`](rationale.md)).
- `[TEST]` `suggestion` — `game/test/test_shell_open.gd`: the shell builds its own `Pack` over the default `user://progress.cfg`, so the default-pack cases are not hermetic on a machine with a real save. The new reset cases seed a test path correctly; applying the same path to the shell-level cases would keep them independent of local data.

### Notes

- `Code lint`, `Unit tests`, `Coverage`, `Integration harness`, `Spec lint`, and `PR hygiene` are green on all three PRs (`gh pr checks 194/199/213`).
- Structure and layering continue the existing patterns: `CMP-shell` calls `CMP-pack` (ADR-0004), the gallery raises intents instead of routing or writing, `ProgressFile` is the only file writer and lives beside `ProgressRules` in L3, and the screens keep their palette/presentation helpers.
- `ProgressRules.restore` normalizes stored fields to `SCH-progress` I1–I3, including the "in progress implies a mark" rule, so an edited file cannot produce an invalid record.
- No `pocs/` paths touched; no assets changed.
