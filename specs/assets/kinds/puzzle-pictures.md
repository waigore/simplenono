# Asset Kind: Puzzle pictures

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Puzzle pictures
- **Source types**: AI generation; Human-made (`register-asset`)
- **Style**: Cool clinical look ([`AES.P1`](../../aesthetics/aesthetics.md))
- **Tool roles**: [`TL.1`](../tools.md), [`TL.2`](../tools.md)
- **Approval**: As hub
- **Serves**: Gallery thumbnail, result morph ([`entities/puzzle.md`](../../design/entities/puzzle.md), [`PER.R5`](../../view/perception.md))

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Each pack [puzzle](../../design/entities/puzzle.md) | Square picture and N×N pixel picture | 2 |
| V2 | Subject class | No per-puzzle multi/single (or multi/holed) tag or quota | Ban |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Pixel grid | 1:1 with puzzle size (N×N colour); nearest-upscale |
| S2 | Fill band | Luma threshold fills cells; band K2 |
| S3 | Clues | Run lengths of the fill |
| S4 | Solvability | Unique line-logic, else regenerate |
| S5 | Background | Flatten vignette so borders are not fills |
| S6 | Generated picture | Stored square; pixel file is its BOX downsample to N×N |

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
- **Style binding**: None — no Recraft; Cheaper Inference only ([`tools.md`](../tools.md) TL.1)
- **Aesthetics**: [`AES.P1`](../../aesthetics/aesthetics.md); no gore/horror
- **Built from**: None
- **Refresh when**: aesthetics change or review Fail

#### Prompt policy

- **Compose**: subject-first; append master + negative.
- **Master**: calm clinical still-life or creatures; clear silhouette; readable at N×N
- **Negative**: gore; horror; playful chrome

## Recipes

### R1 — Flux → nonogram (offline)

- **Source type**: AI generation
- **Tool role**: TL.1 then TL.2
- **Inputs**: size N; subject prompt (V1)
- **Prompt template (bootstrap)**: clinical {subject}; compose with `prompt_policy`
- **Prompt template (series)**: N/A — SS1 `none`
- **Settings**: `flux-2-max`; keep square; BOX copy (S6)
- **Seed policy**: n/a — no seed
- **Post-processing**: flatten vignette; luma (S2); no hole-close; line-logic (S4); else new prompt
- **Outputs**: both catalogued pictures, pack fill/clues

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Size | Inspect | N×N colour cells (S1) |
| K2 | Fill band | Count | 25–45% of `size²`: 25–45 at 10×10, 56–101 at 15×15, 100–180 at 20×20 |
| K3 | Unique line-logic | Offline judge | Pass S4 |
| K4 | Calm, readable subject | Review | [`AES.P1`](../../aesthetics/aesthetics.md) / `prompt_policy`; silhouette reads at N×N; a sentence recorded, no class word; one mass passes |
| K5 | Pack look | Closing review | 200 approved V1 pairs, files resolve, regeneration record per size band (B1), variety (V2) judged on pictures |
| K6 | Both stored | Inspect | Square and N×N both catalogued |

## Naming

- **Handle name**: `puzzle-pictures/<puzzle-id>-generated` and `puzzle-pictures/<puzzle-id>-pixel`
- **Path**: under `game/assets/` from handle ([ADR-0003](../../adr/decisions/0003-catalog-asset-roots.md))
