# Notes — #103 accept

## What was judged

Asset ID issuance and catalog CI validation as merged: `.github/scripts/new_asset_id.py` (UUIDv7 minter, `is_asset_id`) and `.github/scripts/asset_catalog.py` (catalog integrity check run by `Spec lint`), together with the guidance that makes issuance the only route to an ID — including the `manage-asset` wiring from PR #161.

Both acceptance criteria are decidable from the repository by running the shipped commands, so this run reproduces them directly and does not inherit the verification comment.

## Why this is not a playtest

[`playtest.md`](../../../../../specs/playtest/playtest.md) requires a run only when an issue's deliverables change playable behaviour. This delivers Python CI tooling and the documentation that points at it; it ships no game or interface outcome. The merged deliverable is three docs/skill files, and the scripts it validates are covered by 80 unit tests. No protocol from [`coverage.md`](../../../../../specs/playtest/coverage.md) is in scope, so no story IDs are judged and the protocol table is empty by design, not by omission. Per [`evidence.md`](../../../../../specs/playtest/evidence.md), no `screenshots/` is required and none is missing.

## Method

- Clean detached worktree at `origin/main@4ebf9e9`, i.e. the tree after the deliverable merged as `98ed6ae` (PR #161). Nothing was judged against a working branch or an implementation claim.
- **Positive + negative for the catalog check**, because a green run alone cannot show that the check bites: the catalog was first validated clean (exit 0), then one real entry's `id` was mutated to `not-a-uuid7` and `asset_catalog.py` was expected to fail. It reported `[I2]` with exit 1. The entry was restored byte-for-byte from a backup and re-checked clean, with `git status` empty.
- **Shape checks were independent of the module's own claim**: the printed IDs were matched against the UUIDv7 regex directly, not only through `is_asset_id`. `is_asset_id` was exercised in the negative direction on a UUIDv4 and an uppercased ID.
- The unit tests and `Spec lint` were run on the same tree so the evidence is from one build.

## Non-blocking observations (for the planner, not filed)

1. **Deliverable arrives in two waves.** `new_asset_id.py` and the `Spec lint` step landed during the template/bootstrap work; #161 closed only the `manage-asset` guidance gap. Acceptance covers the merged state, which is what the criteria describe, so no follow-up is needed — noting it so a later reader does not expect a single merge for the whole task.
2. **The `Spec lint` job name carries the catalog check.** `asset_catalog.py` has no separate required check; it passes or fails `Spec lint`. That satisfies the criterion, but a catalog break will surface as a spec-lint failure rather than under an asset-named check.
3. **`specs/view/glossary.md` still emits a duplicate-definition warning** for `Diagram`. Pre-existing and unrelated to this task; recorded here only so it is not mistaken for new noise from #103.
