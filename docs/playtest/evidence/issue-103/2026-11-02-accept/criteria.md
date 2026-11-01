# Criteria — #103 accept

Checked against `origin/main@4ebf9e9` in a clean detached worktree containing the merged deliverable `98ed6ae` (PR #161), with the earlier script landings that the issue names. Python 3.12.13.

| # | Criterion | Verdict | How it was checked | Evidence |
|---|-----------|---------|--------------------|----------|
| 1 | Issued IDs are UUIDv7 | Pass | `python3 .github/scripts/new_asset_id.py -n 8` printed eight IDs; all eight match `^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$` (version nibble `7`, variant `8/9/a/b`), all distinct. The module's `is_asset_id` accepts every printed ID and rejects a UUIDv4 (`3f2504e0-…`) and an uppercased ID | `logs/issued-ids.log`, `logs/ids-validate.log` |
| 2a | Valid entries pass `asset_catalog.py` | Pass | `python3 .github/scripts/asset_catalog.py` → `Asset catalog: 0 error(s).`, exit 0 over the five catalogued entries | `logs/catalog-valid.log` |
| 2b | An intentionally broken catalog entry fails via `asset_catalog.py` | Pass | Mutated a real entry (`01a19655-13d1-7499-ad4d-6079f4889628.json`) `id` to `not-a-uuid7`: `ERROR: … [I2] 'id' is not a lowercase UUID version 7`, `Asset catalog: 1 error(s).`, **exit 1**. Restored the entry: `0 error(s)`, exit 0, `git status` clean | `logs/catalog-broken.log`, `logs/catalog-restored.log` |

## Supporting checks

- **CI wiring.** `.github/workflows/spec-lint.yml` runs `python3 .github/scripts/asset_catalog.py` as the `Check asset catalog` step under `Spec lint`; `Spec lint` is a required check on `main`.
- **Issuance guidance.** `new_asset_id.py` is cited as the only way to mint an asset ID by `specs/assets/catalog.md` **Asset ID**, `.agents/rules.md`, `.github/README.md`, `docs/spec-lint.md`, `register-asset`, and — via PR #161 — `manage-asset` step 2. That last path was the gap #161 closed: both skills that can create an asset ID now name the minter.
- **Tests.** `python3 -m unittest discover -s .github/scripts/tests` → 80 tests, `OK`, exit 0; `test_new_asset_id.py` and `test_asset_catalog.py` cover the two criteria directly.
- **Spec lint.** `python3 .github/scripts/spec_lint.py` → 0 errors, 1 pre-existing `specs/view/glossary.md` warning (unrelated).
- **Deliverable merged.** `git show 98ed6ae --stat` → three files, all docs/skill guidance: `.agents/skills/manage-asset/SKILL.md`, `.github/README.md`, `docs/spec-lint.md`. No `game/` path.
