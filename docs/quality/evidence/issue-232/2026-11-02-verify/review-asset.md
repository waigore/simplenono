## Asset review: Pass

**Scope:** PR #291 — the eight entries for `pack-000`–`pack-003` (`picture-id` = TL.1 generated, `pixel-picture-id` = TL.2 pixel).

### Findings

- none

### Needs human: none

### Checked

- **Catalog** — all eight entries carry `kind_spec: AK-puzzle-pictures`, `state: approved`, `coverage: ["V1"]`,
  `recipe: AK-puzzle-pictures.R1`, `license`, `review.verdict: Pass`, `serves` (`E-puzzle.P5`/`E-puzzle.P6`, `PER.R5`,
  `ACC.G3`), and the full `generation` shape (`prompt`, `negative_prompt`, `tool`, `operation`, `settings`, `seed`,
  `inputs`, `steps`). `inputs.style_anchors: []` and no `series` object, correct for SS1 `none`. Tool roles are
  `{role: TL.1|TL.2, adr: adr-free}`. Each pixel entry names its square in `inputs.base_assets`. Handles are
  `puzzle-pictures/<pack-id>-generated` / `-pixel`. All served IDs exist in `specs/`. `asset_catalog.py` → 0 errors,
  `asset_manifest.py --check` → 0 errors, and all eight manifest rows resolve to the committed files.
- **Specification** — S1/K1: pixel files are 10×10. S2/K2: filled counts 30, 28, 29, 32 — all inside 25–45.
  S3: `row-clues`/`col-clues` are run lengths, 10 lists each, and equal the clues the judge computes from each pixel.
  `solution-fills` is the schema's sorted `[row, column]` list and equals the pixel's `Y < 128` cell set exactly
  (30, 28, 29, 32 cells).
  S4/K3: `judge` reports `solutions: 1`, `logic_solved: true`, `matches_pixel: true` for every puzzle.
  S5: everything outside the outer 5% band is replaced with the median of the outer 1% ring before counting; no
  hole-closing step exists in `box_downsample` or `fills`. S6/K6: re-running the stated derive in the verify
  worktree reproduced all four committed pixels byte-identically.
- **Style (AES.P1, K4)** — measured on the committed pixels: subject means are slate blue-grey with R<G<B for all four
  (e.g. pack-000 `(84.2, 91.7, 102.8)`), against pale cool-grey backgrounds (`≈(205–216)`), a luma gap of ~123–139.
  Cool-toned and high-contrast; no warm, gaudy, cute, gore, or horror traits. Prompt settings carry
  `subject_class` — `single-subject` for pack-000/003, `multi-subject and/or holed` for pack-001/002, matching the
  issue's index rule.
- **Readability** — silhouettes resolved to a 10×10 grid read as a compact still-life mass (pack-000/003), three
  separated subjects with clear gaps (pack-001), and a two-part form (pack-002). All read at board size.
- **Content limits and license** — nothing against the content limits; license names the generation tool and grants
  use and modification.

### Keep in view (not a finding)

`game/presentation/shell.gd` `_picture_for` returns `null` when an id is absent from the manifest, so these pictures
stay dark on the gallery and result screens until the drawing work in #94 and #95 lands. That is the issue's stated
out-of-scope list, not an asset defect.
