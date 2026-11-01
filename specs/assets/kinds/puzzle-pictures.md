# Asset Kind: Puzzle pictures

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Puzzle pictures
- **Source types**: AI generation; Human-made (`register-asset`)
- **Style**: Cool clinical look ([`AES.P1`](../../aesthetics/aesthetics.md)); calm subjects
- **Tool roles**: [`TL.1`](../tools.md), [`TL.2`](../tools.md)
- **Approval**: As hub
- **Serves**: Pack solution pictures ([`entities/puzzle.md`](../../design/entities/puzzle.md)); gallery thumbnail; result morph ([`PER.R5`](../../view/perception.md))

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Each pack [puzzle](../../design/entities/puzzle.md) | One full-colour solution at that size (10 / 15 / 20) | 1 |
| V2 | Pack art mix | ~30% single-subject; ~70% multi-subject and/or holed | Across 200 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Pixel grid | 1:1 with puzzle size (N×N colour); nearest-upscale for display |
| S2 | Fill band | Luma threshold → ~25–45% filled cells |
| S3 | Clues | Run lengths from the fill set |
| S4 | Solvability | Unique + fully line-logic; else discard and regenerate |
| S5 | Background | Flatten vignette so border is not false fills |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Pack sizes | 10×10×10 + 15×15×170 + 20×20×20 | [`entities/puzzle.md`](../../design/entities/puzzle.md) |

## Style series

### SS1 — primary

- **State**: none
- **Modality**: visual
- **Enforce**: soft
- **Style anchors**: None yet
- **Style binding**: None — **project exception**: no Recraft; Cheaper Inference only ([`tools.md`](../tools.md) TL.1)
- **Aesthetics**: [`AES.P1`](../../aesthetics/aesthetics.md); calm clinical; no gore/horror
- **Built from**: None
- **Refresh when**: aesthetics change or review Fail pattern

#### Prompt policy

- **Compose**: subject-first; append master + negative.
- **Master**: calm clinical still-life or creatures; clear silhouette; flat light; readable at N×N
- **Negative**: playful chrome; gore; horror; busy vignettes; tiny unreadable detail

## Recipes

### R1 — Flux → nonogram (offline)

- **Source type**: AI generation
- **Tool role**: TL.1 then TL.2
- **Inputs**: size N; subject prompt (V2 mix)
- **Prompt template (bootstrap)**: clinical {subject}; clear gaps if multi; compose with `prompt_policy`
- **Prompt template (series)**: N/A — SS1 `none`
- **Settings**: model `flux-2-max`; square; BOX pixelate to N×N
- **Seed policy**: n/a unless API exposes seed
- **Post-processing**: flatten vignette; luma (S2); no hole-close; unique + line-logic (S4); fail → new prompt (no size fallback)
- **Outputs**: catalogued colour picture + pack fill/clues (authoring/CI only)

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Size | Inspect | N×N colour cells (S1) |
| K2 | Fill band | Count | ~25–45% (S2) |
| K3 | Unique line-logic | Offline judge | Pass S4 |
| K4 | Style calm | Review | AES.P1 / prompt_policy |
| K5 | Mix | Pack audit | Roughly V2 |

## Naming

- **Handle name**: `puzzle-pictures/<puzzle-id>`
- **Path**: under asset root from handle — TBD — which Integration ADR sets the asset root?
