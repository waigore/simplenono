# Issue #610 — K5 pack-look closing review

Date: 2026-11-05. Tree audited: `main@4421dee` (the branch base; the delivered tree is this
PR's head). Author: `issue-workflow-implement-agent` (unattended, parallel id 1).
Kind spec: [`specs/assets/kinds/puzzle-pictures.md`](../../../../../specs/assets/kinds/puzzle-pictures.md)
`V1`, `V2`, `K1`–`K6`; the `K5` row is amended in this PR to make the closing judgement
testable (see [Check 3](#check-3--variety-k5-v2)).
Wiki page (contact sheets and logs): <https://github.com/waigore/simplenono/wiki/Playtest-issue-610-2026-11-05-closing-audit>

This record closes the pack-wide `K5` look judgement for the 200 approved `V1` pairs. It
supersedes the [#294 closing audit](../../issue-294/2026-11-04-closing-audit/manifest.md)
for the current pack, which predates the 30-picture regeneration from #565 (PR #595,
merge `e8a03ea`). Every number below was read from the tree by
[`tools/pack_look_audit.py`](tools/pack_look_audit.py), not taken from slice comments.

## Reproduce

```bash
python3 docs/playtest/evidence/issue-610/2026-11-05-closing-audit/tools/pack_look_audit.py
python3 .github/scripts/asset_catalog.py                 # 0 error(s)
python3 .github/scripts/asset_manifest.py --check        # 0 error(s)
python3 .github/scripts/generate_pack.py --check         # pack.json is current
```

The audit exits non-zero when a pair breaks `K1`–`K3`, when two pairs deliver the same
`N×N` picture, or when a named scene repeats inside a size band. It exits 0 on the
delivered tree.

## Check 1 — 200 approved `V1` pairs, 400 files resolve

Every `pack-000`–`pack-199` row's `picture-id` and `pixel-picture-id` resolves to an
`assets/catalog/` entry with `kind_spec: AK-puzzle-pictures`,
`recipe: AK-puzzle-pictures.R1`, `state: approved`, and `review.verdict: Pass`; both ids
differ on every row (`I5`); all 400 ids resolve through `assets/manifest.json` to a file
that exists under `game/assets/puzzle-pictures/`.

| Size | Puzzles | Approved `V1` pairs | Catalog `review` Pass on both | Files resolve |
|---|---|---|---|---|
| 10×10 | 10 | 10/10 | 20/20 | 20/20 |
| 15×15 | 170 | 170/170 | 340/340 | 340/340 |
| 20×20 | 20 | 20/20 | 40/40 | 40/40 |
| **All** | **200** | **200/200** | **400/400** | **400/400** |

`assets/manifest.json` still lists **406** entries (400 pictures + 6 other assets).

## Check 2 — derive and judge re-check (`K1`–`K3`)

The audit re-runs the `TL.2` rule from every committed square with its own implementation
(flatten the outer 5% frame to the median of the outer 1% ring, exact BOX downsample to
`N×N`, fill at luma < 128) and its own line-logic solver:

- **200/200** squares reproduce their committed pixel cells (max channel difference ≤ 1,
  `S1`, `S5`, `S6`, `K1`, `K6`);
- **200/200** pixel fills equal the committed `solution-fills` and the committed clues
  (`S2`, `S3`, `K2`);
- **200/200** clue sets have exactly one solution, line logic alone reaches it, and it is
  the committed fill set (`S4`, `K3`);
- **200/200** fills sit inside the band (10×10 25–45, 15×15 56–101, 20×20 100–180).

`A+B problems: 0`.

## Check 3 — variety (`K5`, `V2`)

### Method

The pack was read as pictures, not as prompts: one thumbnail contact sheet per size band
plus a sheet of the replaced pairs (wiki page above), and three measured properties over
the 200 committed squares and their `N×N` pixels:

1. **duplicate picture** — two pairs whose `N×N` fill is equal under any rotation or flip
   (the same puzzle twice);
2. **repeated named scene** — two pairs in one size band whose generation prompt names the
   same scene (subject + setting);
3. **near-twin squares** — normalised 32×32 RGB correlation ≥ 0.95, recorded as an
   observation, not a pass/fail rule.

`V2` stays a `Ban`: no per-puzzle multi/single (or multi/holed) tag, quota, or class word
is added anywhere by this review.

### What the review found on `main@4421dee`

| Finding | Count | Detail |
|---|---|---|
| Duplicate pictures (same `N×N` fill under rotation/flip) | **6 groups / 13 redundant rows** | `pack-011/049/092`, `pack-019/058`, `pack-021/081/098/111/144`, `pack-037/083/140`, `pack-046/146/151`, `pack-063/160/167` |
| Repeated named scene inside a band | **3 groups** | "lighthouse coast" ×2 at 10×10 (`000`, `002`), ×3 at 20×20 (`182`, `184`, `188`); market-awning ×2 at 15×15 (`035`, `137`) |
| Near-twin squares (correlation ≥ 0.95) | 19 pairs | all between version-1 pairs |
| Identical generation prompts | 23 groups / 168 pairs | the pre-#564 clinical band (see residual) |
| Fills with a dihedral symmetry | 44 pairs | all version 1, all 15×15 |

The six "lighthouse coast" pairs and the `pack-035` / `pack-137` near-twin are the two
observations #565's verification recorded for this review; the duplicate-picture groups
are new and are the same failure in a harder form — the pack shipped the same puzzle
twice under two ids.

### Resolution

Every group the review failed is resolved by regeneration to a distinct scene; nothing
outside the failed groups was touched. The kept member of each group is the
lowest-numbered pair (and, for the lighthouse scene, one per size band).

| Group | Kept | Regenerated | Reason |
|---|---|---|---|
| `pack-011/049/092` | `pack-011` | `pack-049`, `pack-092` | same `N×N` picture |
| `pack-019/058` | `pack-019` | `pack-058` | same `N×N` picture |
| `pack-021/081/098/111/144` | `pack-021` | `pack-081`, `pack-098`, `pack-111`, `pack-144` | same `N×N` picture |
| `pack-037/083/140` | `pack-037` | `pack-083`, `pack-140` | same `N×N` picture |
| `pack-046/146/151` | `pack-046` | `pack-146`, `pack-151` | same `N×N` picture |
| `pack-063/160/167` | `pack-063` | `pack-160`, `pack-167` | same `N×N` picture |
| lighthouse coast, 10×10 | `pack-000` | `pack-002` | repeated named scene |
| lighthouse coast, 15×15 | `pack-018` | — | kept: the only lighthouse-coast pair in the 15×15 band, so the per-band rule allows it |
| lighthouse coast, 20×20 | `pack-182` | `pack-184`, `pack-188` | repeated named scene |
| market awning, 15×15 | `pack-035` | `pack-137` | near-twin composition |

`pack-018` is the 15×15 member of the six-pair "lighthouse coast" concentration named in the
issue. It is the only lighthouse-coast pair in its size band, so the amended `K5` keeps it
and no regeneration is needed; the other five are resolved in the rows above.

Each regenerated pair keeps its `picture-id` / `pixel-picture-id`, raises its version,
keeps the replaced generation in `history`, and carries a fresh `review` Pass with the
`K1`–`K4` facts re-checked (grid size, fill band, unique line logic, colour and
asymmetry measurements, a recorded scene sentence, no class word). The per-pair table is
in [`notes.md`](notes.md).

### After the change

| Property | Before | After |
|---|---|---|
| Distinct `N×N` pictures | 187 / 200 | **200 / 200** |
| Duplicate-picture groups | 6 | **0** |
| Repeated named scenes inside a band | 3 | **0** |
| Near-twin square pairs (≥ 0.95) | 19 | 6 (all version 1) |
| Identical-prompt groups / pairs | 23 / 168 | 20 / 148 |
| Fills with a dihedral symmetry | 44 | 32 (all version 1) |
| 10×10 mean saturation / hue span | 0.313 / 0.563 | 0.331 / 0.500 |
| 15×15 mean saturation / hue span | 0.115 / 0.075 | 0.129 / 0.105 |
| 20×20 mean saturation / hue span | 0.195 / 0.381 | 0.190 / 0.401 |

### Residual observations (recorded, not resolved here)

The pack still carries the pre-#564 clinical tail: 147 of the 170 15×15 pairs are at
catalog version 1, generated from 20 shared silhouette descriptions (one description
covers 59 pairs), with a mean saturation of 0.13 against 0.33 in the regenerated 10×10
band, and 32 of them deliver a fill that is symmetric under a rotation or flip. That is
the retired clinical look, not a duplicate-picture or repeated-scene failure under the
amended `K5`, and the product owner pegged the colourful regeneration at 30 pairs
([#566](https://github.com/waigore/simplenono/issues/566), #563). Replacing the tail is a
PO-sized decision; this record measures it so that decision can be taken with numbers.

## Check 4 — regeneration record per size band (`B1`)

This review's own runs (all prompts and judge facts are in the catalog `generation`
records; the attempt plan and slice manifests are on the wiki page):

| Size band | Pairs replaced | Squares generated | Accepted | Discarded |
|---|---|---|---|---|
| 10×10 | 1 | 3 | 1 | 2 |
| 15×15 | 14 | 58 | 14 | 44 |
| 20×20 | 2 | 50 | 2 | 48 |
| **All** | **17** | **111** | **17** | **94** |

The 20×20 band needed 47 attempts for `pack-188` alone (a 20×20 picture must be both
unique under line logic and inside the 25–45% fill band); the accepted square is the
sailing-ship scene recorded in its catalog entry. The #565 record for the earlier 30
pairs stands in that issue's implementation comment and is not duplicated here.

## Verdict

- **`K5` — Pass** on the amended wording: 200 approved `V1` pairs, 400 files resolve, a
  regeneration record per size band, no two pairs deliver the same `N×N` picture, and no
  named scene is used by more than one pair per size band.
- **`V2` — Pass**: no per-puzzle class, quota, or tag was added; the class-free look
  judgement is the one above.
- **Residual** — the pre-#564 clinical tail (147 version-1 15×15 pairs, 32 symmetric
  fills, 20 shared silhouette descriptions) is measured above and left for a PO-sized
  follow-up; it is outside the amended `K5` wording and outside the 30-pair peg.

## Paths

- In-repo: this `manifest.md`, [`notes.md`](notes.md) (per-pair table and method notes),
  and [`tools/`](tools/) (`pack_look_audit.py`, `contact_sheet.py`, `apply_regen.py`).
- Wiki: <https://github.com/waigore/simplenono/wiki/Playtest-issue-610-2026-11-05-closing-audit>
  — `contact-10x10.png`, `contact-15x15.png`, `contact-20x20.png`,
  `contact-resolved.png`, `pack-look-audit-baseline.json`, `pack-look-audit-final.json`,
  `slice.log`, `slice-pass2.log` … `slice-pass8.log`.
