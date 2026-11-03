# Epic #294 — puzzle picture pack, closing audit

Date: 2026-11-04. Tree: `main@348a6f3`. Author: `issue-workflow-implement-agent` (unattended, parallel id 1).
Kind spec: [`specs/assets/kinds/puzzle-pictures.md`](../../../../../specs/assets/kinds/puzzle-pictures.md) `V1`, `K1`–`K6`.

This record closes the four pack-wide checks in the #294 body. It asserts nothing per puzzle beyond what each
slice's own comment already recorded against the shared picture bar; every number below was read from `main`,
not from slice claims. #252 and #254 have no picture-slice evidence directory, so for them the shipped catalog
and pack rows are the record.

## Reproduce

```bash
python3 .github/scripts/asset_manifest.py --check      # Asset manifest: 0 error(s).
python3 .github/scripts/generate_pack.py --check       # game/data/pack.json is current
python3 docs/playtest/evidence/issue-294/2026-11-04-closing-audit/tools/pack_audit.py
```

## Check 1 — a catalogued `V1` pair for every puzzle, `review` Pass

Every `pack-000`–`pack-199` row's `picture-id` and `pixel-picture-id` resolves to an `assets/catalog/` entry with
`kind_spec: AK-puzzle-pictures`, `recipe: AK-puzzle-pictures.R1`, `state: approved`, and `review.verdict: Pass`.
The two ids differ on every row (`I5`).

| Size | Puzzles | Approved `V1` pairs | Catalog `review` Pass on both | Fill range |
|---|---|---|---|---|
| 10×10 | 10 | 10/10 | 20/20 | 27–40 |
| 15×15 | 170 | 170/170 | 340/340 | 56–100 |
| 20×20 | 20 | 20/20 | 40/40 | 101–175 |
| **All** | **200** | **200/200** | **400/400** | — |

Fill ranges sit inside the band the kind fixes: 25–45 of 100, 25–45% of 225 (56–101), 25–45% of 400 (100–180).
Clues on every row are the run lengths of its `solution-fills` (`S3`, `I1`–`I3`).

## Check 2 — `assets/manifest.json` resolution

All **400** picture ids resolve through `assets/manifest.json` to one file each under `game/assets/`
(`game/assets/puzzle-pictures/` holds 200 generated squares and 200 N×N pixels); 400 listed paths for 400 ids, none
missing and none absent from disk.

## Check 3 — subject mix (`V2`, `K5`)

The pack was delivered under the pre-#486 `V2` (~30% single-subject / ~70% multi), whose per-puzzle class the
product owner retired on 2026-11-03 (option 3, [#486][486]); PR #495 rewords `V2`/`K5` to a class-free look
audit. Measured from the delivered catalog as recorded at delivery time:

| Size | single-subject | multi-subject and/or holed | unlabelled |
|---|---|---|---|
| 10×10 | 3 | 7 | 0 |
| 15×15 | 51 | 119 | 0 |
| 20×20 | 4 | 8 | 8 (pack-192–pack-199) |
| **All** | **58** | **134** | **8** |

The index rule that shaped the slices (index mod 10 ∈ {0, 3, 7}) names 60 single-subject out of 200 — 30%,
exactly the `V2` target. The eight delivered entries that disagree with it are pack-192–pack-199, unlabelled
because those last two slices were generated after the class was retired and never wrote one. **192 of 200**
delivered entries carry the label the index rule names.

Under the class-free reading this is no longer a per-puzzle target: the pack look is the `K5` closing judgement —
200 pictures, all approved, all calm-clinical and readable at N×N from their silhouettes, shipped as one
variety-checked set. No picture is regenerated for a class.

## Check 4 — regeneration record and discard rate

Per-slice regeneration records (generated / judge- or look-rejected / discarded) live in each slice's
implementation and acceptance comments; they are not duplicated here. What those records do not contain is a
pack-level upload count: the generation runs were not logged in one place, so the discard rate **cannot be
stated numerically** without re-deriving it from the slices' comments alone. The measurable part of the check —
that every delivered pair is approved, in band, one-solution and line-logic-solvable — is checks 1–3 above:
**0 delivered pictures outside the bar.**

[486]: https://github.com/waigore/simplenono/issues/486
