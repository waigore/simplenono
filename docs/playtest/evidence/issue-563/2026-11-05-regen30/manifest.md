# Epic #563 — puzzle-picture regeneration record (30 pack entries)

- **Date:** 2026-11-05
- **Author:** `issue-workflow-implement-agent` (unattended, parallel id 1, assigned #563)
- **Tree:** `task/563-colourful-puzzle-picture-regen` based on `task/564-colourful-puzzle-picture-specs@2abf067` (the revised kind spec from PR #570; not yet merged into `main` when this ran)
- **Kind:** [`specs/assets/kinds/puzzle-pictures.md`](../../../../../specs/assets/kinds/puzzle-pictures.md) + [`style-series.md`](../../../../../specs/assets/kinds/puzzle-pictures/style-series.md) + [`recipes.md`](../../../../../specs/assets/kinds/puzzle-pictures/recipes.md) as revised by #564 (`SS1` is `none`; recipe `R1` bootstrap template; checks `K1`–`K6`)
- **Record:** `regen-records.json` beside this file — per-puzzle subject, prompts, judge sequence, accepted attempt, request id, billing

## Scope delivered

Thirty pack entries regenerated under the revised policy (colourful, multi-element complex scenes with real backgrounds, completely asymmetrical, no clinical look): every 10×10 row, and the first ten rows of the 15×15 and 20×20 bands by pack order.

| Band | Rows | Generated (all rounds) | Accepted |
|------|------|------------------------|----------|
| 10×10 | pack-000…pack-009 (all ten) | 48 | 10/10 |
| 15×15 | pack-010…pack-019 (first ten of 170) | 87 | 10/10 |
| 20×20 | pack-180…pack-189 (first ten of 20) | 174 | 10/10 |
| **Total** | **30 rows** | **309** | **30/30** |

Rounds: 21 entries accepted in round 1; 4 (pack-008, pack-012, pack-018, pack-180) in round 2 with new subjects; 5 (pack-016, pack-181, pack-183, pack-185, pack-187) in round 3 with new subjects again. Every attempt is a distinct composed prompt per `R1`'s template + `SS1` master/negative; the judge (K1–K3) is the fixed `puzzle_derive.py` rule — nothing was tuned per image; only prompts changed between attempts.

## Deliverables

- 30 generated squares + 30 pixel pictures overwritten in place (`game/assets/puzzle-pictures/pack-<id>-{generated,pixel}.png`); catalog entries `APR.update`d (version 2, `history` keeps the prior generation, per `specs/assets/procedures/update.md`)
- `game/data/pack.json`: 30 rows re-derived from the new approved pixels via `generate_pack.py --puzzle` (fills, row/col clues per `S3`); a full regen re-run is byte-stable for the other 170 rows
- This record

## Reproduce

```bash
# K1/K2/K3/K6 on every committed pixel, and S6 (pixel == BOX copy of the square):
python3 .github/scripts/puzzle_derive.py judge --pixel game/assets/puzzle-pictures/pack-000-pixel.png --size 10
python3 .github/scripts/puzzle_derive.py derive --square game/assets/puzzle-pictures/pack-000-generated.png \
  --pixel /tmp/recheck.png --size 10   # byte-equal to the committed pixel for all 30
# Pack rows:
python3 .github/scripts/generate_pack.py   # "is current"
# Catalog integrity (I1–I8 incl. I3 Pass-review-per-version):
python3 .github/scripts/asset_catalog.py   # 0 error(s)
```

## Checks

- **K1 / K6** — every pair is N×N + square, both stored and catalogued: 30/30 pass (judge + `asset_catalog.py`).
- **K2** — fill band 25–45% (`10²: 25–45`, `15²: 56–101`, `20²: 100–180`): 30/30 pass, judge re-run on the committed files.
- **K3** — unique line logic, solution equals the pixel fill: 30/30 pass, judge re-run on the committed files.
- **S6** — stored pixel is the BOX copy of the stored square: byte-equal re-derive 30/30.
- **K4** (look, per the revised pillar scope — picture content exempt from `AES.P1`) — recorded per entry in the catalog `review` blocks (verdict `Pass`, 2026-11-05, reviewer `agent`): every accepted square was read and judged colourful, multi-element, with a real background reaching the borders, and completely asymmetrical; no gore/horror; no centered single mass on empty ground. This look pass belongs to this run's own pipeline review; the independent verification pass re-judges it.
- **Pack look (K5)** — this record is the regeneration record per size band; the 200-picture pack look (variety `V2`, all pairs approved) stays with the pack's closing review.

## Local CI parity at this tree

`asset_catalog.py` 0 error(s); `asset_manifest.py --check` 0 error(s); `generate_pack.py --check` current; `spec_lint.py` 0 error(s), 1 pre-existing glossary warning; `.github/scripts/tests` 186 tests OK; GUT suite 365/365 after re-pinning `ACHIEVED_CELL` (see below); smoke run clean; `gdformat --check` and `gdlint` clean.

## Note on the pinned board-framing constants

The regen gives the replaced rows longer clue runs (colourful scenes have many-run lines), which grows the R2 clue bars, so the mobile board reaches smaller cells than the `ACHIEVED_CELL` constants pinned in #520. `game/test/test_puzzle_board.gd` constants re-measured from the same layout chain on this tree: portrait 26→25 (10), 18→17 (15), 14→13 (20), landscape 18→17 (10); landscape 15/20 unchanged (12 / 9). The game-side pin is the only `game/` code change in this PR.
