# PoC requests

Logged exploration requests (not specs). Contract: [`docs/pocs.md`](../pocs.md), notes overview: [README.md](README.md).

Each open request should become a GitHub task or epic before build. Status `filed` once `#n` exists.

## Entries

### image-nonogram-pipeline

- **Purpose**: Prove that Flux (`flux-2-max` via Cheaper Inference) full-colour art, pixelated 1:1 to the grid for a natural fill→image morph, plus threshold/morph/adapt/solver, can produce recognizable uniquely solvable puzzles of acceptable difficulty.
- **Scope**: In — generate 1024² full-colour clear-shape subjects; pixelate to N×N; run pipeline for 10×10/15×15; emit pixel source, grid, morph preview, clues. Out — full 200-pack; Recraft style series; Godot UI; catalogued assets; ADR/spec authoring.
- **Desired outcome**: Three generated puzzles with acceptable difficulty (uniquely solvable; mid difficulty band; readable silhouette).
- **Trigger**: user-requested
- **Related**: capture-requirements asset hub; proposed pack/image notes (not yet formalized)
- **Constraints**: `specs/vision.md` calm clinical subjects; `specs/definition/definition.md` 10×10/15×15; `specs/aesthetics/aesthetics.md` content limits (no gore/horror). Catalog roots TBD — PoC artifacts under `pocs/`, not catalogued.
- **Status**: open
- **Issue**: none
