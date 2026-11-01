# Notes — #127 accept

## What was judged

The GDScript lint/format tooling that #127 delivers: the ADR that chooses it, the filled `CC-*` conventions, the `Code lint` steps that enforce them, and the formatting pass that leaves `game/` clean.

Every acceptance criterion is decidable from the repository and from running the pinned tools, so this run judges them directly and asserts a pass rather than inheriting the verification comment.

## Why this is not a playtest

[`playtest.md`](../../../../../specs/playtest/playtest.md) requires a run only when an issue's deliverables change playable behaviour. This one adds a dev-only Python package to a CI job and reformats existing sources; it ships nothing and changes no game or interface outcome. The `game/` files the merge touches were checked to confirm that claim instead of assuming it — the diff is declaration reordering and line wrapping only.

No protocol from [`coverage.md`](../../../../../specs/playtest/coverage.md) is in scope, so no story IDs are judged and the protocol result table is empty by design, not by omission. Per [`evidence.md`](../../../../../specs/playtest/evidence.md), no `screenshots/` is required and none is missing.

## Method

- Clean detached worktree at `main@1fa6659`, i.e. the tree after the deliverable merged as `c864c6b` (PR #146). Nothing was run against a working branch or an implementation claim.
- Pinned `gdtoolkit==4.5.0` installed into a throwaway virtualenv — the same pin `code-lint.yml` installs, so the local verdict and the CI verdict come from the same tool.
- Positive falsification for both enforcement criteria: one deliberate violation to prove the check fails, and one probe file under `pocs/` to prove the exclusion holds rather than merely being unexercised. Both were reverted, and the reverted state was re-checked clean.

## Non-blocking observations (for the planner, not filed)

1. **`Code lint` has no recorded green run on `main` since the deliverable merged.** The workflow's newest `main` run is `1d98d95`, which predates the merge, and the check-runs API reports zero runs for `c864c6b` and `1fa6659`. The local reproduction above is the evidence for the criterion; if the workflow is expected to fire on `push` to `main`, that it did not is worth one look. This accept run does not act on it.
2. **`gdformat`'s output on `rules.gd` is legal but hard to read** — it emits chained-call formatting such as a parenthesised `ClueLines . from_definition(…)`. That is `gdformat`'s own layout at the 100-column width, not a hand-edit, and `CC-2` tells authors not to fight it. If the result is unwanted, the fix is a code-shape change (an intermediate local), not a formatter exception.
3. **`max-public-methods` is disabled repo-wide** (`.gdlintrc`) to accommodate GUT's one-public-method-per-scenario style. That also stops gdlint watching method count in production classes. Reasonable given the ADR, but the exemption is broader than the problem it solves; a per-directory config would be tighter.
4. **`pocs/` currently ships no `.gd` file**, so criterion 4 would pass trivially on an empty exclusion. The probe file in `logs/pocs-excluded.log` is what makes the claim real. Worth remembering next time the exclusion is questioned.
