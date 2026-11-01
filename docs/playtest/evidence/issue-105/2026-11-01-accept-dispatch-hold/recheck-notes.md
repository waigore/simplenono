# Re-check notes — issue #105 accept dispatch hold

Detail behind the two rows of the [`manifest.md`](manifest.md) re-check table that need more
than one line.

## Independent pack audit

No repo validator exists for pack content, so the audit recomputed the shipped pack by hand:

- 200 entries, sizes `10: 10`, `15: 170`, `20: 20`.
- F3/F4 runs recomputed from each F5 and matched; every F5 position lies inside its grid.
- 0 invalid entries.
- 200 unique F1/F6/F7 lines, and F6 ∩ F7 = ∅.

The audit first reported 200 "invalid" entries. That was a transposition bug in the audit
script: it compared `(x, y)` tuples against the repo's `[row, col]` pairs. With corrected
indexing it reports 0 invalid. The pack is not implicated.

## Environment note

`game/.godot/` (import cache) is absent in a fresh dispatched worktree. The bare suite command
exits non-zero with "Some GUT class_names have not been imported". `.github/workflows/unit-tests.yml`
runs `godot --headless --path game --import` before the suite; `docs/coding-conventions.md`
Unit tests row shows only the suite command. This run imported first, then ran the documented
command (52/52). Recorded because this is the second dispatch to hit the same local setup gap.
