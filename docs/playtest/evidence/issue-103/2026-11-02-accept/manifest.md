# Acceptance run — issue #103 (accept)

- **Issue:** #103 Asset ID issuance & catalog CI validation (`type:task`, parent #92)
- **Run id:** `2026-11-02-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-02
- **Build / session id:** `main@4ebf9e9`, containing the deliverable merge `98ed6ae` (PR #161). No `TEL.3` session id exists — this deliverable adds no telemetry.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless, local reproduction of the `Spec lint` asset-catalog check and the ID minter
- **Under acceptance:** `.github/scripts/new_asset_id.py` issuance guidance and the `asset_catalog.py` CI check, including the `manage-asset` wiring from PR #161

## Scope

**No playtest protocols are in scope.** Per [`playtest.md`](../../../../../specs/playtest/playtest.md), a run is required only when deliverables change playable behaviour. This is Python CI tooling plus documentation for the asset catalog; its merged diff over `game/` is empty. The criteria judged are the two acceptance criteria in the issue body, against [`criteria.md`](criteria.md).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| Playtest protocols | **not applicable** | Tooling/docs deliverable; no playable behaviour changes, so the gate does not apply and no screenshots are required |
| AC 1 — issued IDs are UUIDv7 | **pass** | 8/8 printed IDs match version 7 and RFC 4122 variant; all unique; `is_asset_id` accepts them and rejects a UUIDv4 and an uppercased ID |
| AC 2a — valid catalog passes | **pass** | `asset_catalog.py` → `0 error(s)`, exit 0 over the 5 catalogued entries |
| AC 2b — intentionally broken entry fails | **pass** | Mutated one entry's `id` to `not-a-uuid7`: `ERROR … [I2] 'id' is not a lowercase UUID version 7`, `1 error(s)`, exit 1; restored → `0 error(s)`, exit 0 |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes | [`notes.md`](notes.md) | present |
| Criteria | [`criteria.md`](criteria.md) | present |
| Tool versions | [`logs/tool-versions.log`](logs/tool-versions.log) | `Python 3.12.13` |
| Issued IDs | [`logs/issued-ids.log`](logs/issued-ids.log) | 8 UUIDv7 values, exit 0 |
| ID shape check | [`logs/ids-validate.log`](logs/ids-validate.log) | 8/8 valid, unique, v4/uppercase rejected |
| Catalog valid | [`logs/catalog-valid.log`](logs/catalog-valid.log) | `0 error(s)`, exit 0 |
| Catalog broken | [`logs/catalog-broken.log`](logs/catalog-broken.log) | `[I2]`, `1 error(s)`, exit 1 |
| Catalog restored | [`logs/catalog-restored.log`](logs/catalog-restored.log) | `0 error(s)`, exit 0; tree clean |
| Script unit tests | [`logs/unittest.log`](logs/unittest.log) | 80 tests, `OK`, exit 0 |
| Spec lint | [`logs/spec-lint.log`](logs/spec-lint.log) | 0 errors, 1 pre-existing glossary warning, exit 0 |
| CI + docs wiring | [`logs/wiring.log`](logs/wiring.log) | `Check asset catalog` step present; issuance cited by 6 paths; merged diff |
| Screenshots | — | not required: no playable behaviour |

No `screenshots/` folder exists because no protocol requires one; [`evidence.md`](../../../../../specs/playtest/evidence.md) exempts this case from the graphical-run rule.
