# PoC: Image → nonogram pipeline

Exploration artifact, not production code. Contract: `docs/pocs.md`, `docs/poc-style-assets.md`.

- **Question**: Can Flux (`flux-2-max` / Cheaper Inference) full-colour art, pixelated 1:1 to the grid for a natural fill→image morph, plus threshold fill-band → morphology → uniqueness Adapt → solver difficulty, yield recognizable uniquely solvable nonograms of acceptable difficulty?
- **Type**: engine
- **Issue**: none
- **Request log**: `docs/requirements/poc-requests.md` → image-nonogram-pipeline
- **Purpose / scope / outcome**: Prove the pipeline on generated silhouette images. In: generate images, run pipeline, report metrics. Out: pack shipping, Recraft series, UI, catalog. Outcome: **three** puzzles with acceptable difficulty.
- **Engine**: none (Python tooling only)

## Constraints

| Ref | How it constrains the experiment |
|-----|----------------------------------|
| `specs/vision.md` | Calm clinical subjects; no playful chrome |
| `specs/definition/definition.md` | Grid sizes 10×10 or 15×15 |
| `specs/aesthetics/aesthetics.md` | No gore/horror; calm subjects |

## Style

| Style element | Where it is seen or heard |
|---------------|---------------------------|
| None | Experiment images are pipeline I/O, not product style |

## Assets

| Asset ID | Handle | Source type | Kind spec | Coverage rule | Tool role (ADR) | Version | State | Review |
|----------|--------|-------------|-----------|---------------|-----------------|---------|-------|--------|
| None | | | | | | | | |

## Pipeline findings

| ID | Finding | Element | Filed as |
|----|---------|---------|----------|
| PF1 | Catalog roots still TBD — outputs stay under `pocs/` | assets hub | deferred to ADR |

## What was tried

See latest `out/report.json` after re-run. Pipeline: Flux full-colour 1024² → BOX pixelate to N×N RGB (flatten border vignette) → luma threshold (25–45% fill) → morph/dilate → uniqueness Adapt → line-logic judge; `source.png` is nearest-upscaled pixel colour for morph. TLS: `SSL_CERT_FILE`=certifi on this macOS Python.

## Promotion act

| Claim or behavior | Choice | Note |
|-------------------|--------|------|
| <!-- fill in --> | <!-- fill in: keep, drop, or adapt --> | <!-- fill in --> |

Act: incomplete

## Run

```bash
# From repo root; needs CHEAPERINFERENCE_API_KEY in this shell
python3 -m pip install --user numpy pillow   # once
python3 pocs/image-nonogram-pipeline/run_poc.py
```

Outputs under `pocs/image-nonogram-pipeline/out/<slug>/`:

- `source_raw.png` — Flux full-colour 1024²
- `source.png` — **pixel-colour** solution (N×N colours, nearest-upscaled; morph target)
- `grid.png` — binary fills
- `morph_preview.png` — colour only on fill cells
- `puzzle.json` — clues, grid, `pixels_rgb`
- `out/report.json`

## Known limitations

- Not catalogued; not wired into Godot.
- Line-logic + limited DFS uniqueness; difficulty is heuristic (logic depth / fill band).
- Acceptable difficulty = unique + fill 28–42% + solvable mostly by line logic (DFS depth ≤ 2).
