# Asset Kind: Puzzle pictures

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Puzzle pictures
- **Source types**: AI generation; Human-made (`register-asset`)
- **Style**: [`AES.P2`](../../aesthetics/aesthetics.md) / [`AES.P3`](../../aesthetics/aesthetics.md); [`AES.P1`](../../aesthetics/aesthetics.md) is chrome-only (aesthetics pillar scope) — picture content is colourful multi-element scenes, not required to be cool-toned or clinical
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
| S5 | Background | Real scene background allowed and may reach the borders; borders may be fills — no flat/empty-border or vignette-flatten requirement |
| S6 | Generated picture | Stored square; pixel file is its BOX downsample to N×N |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Pack sizes | 10×10×10 + 15×15×170 + 20×20×20 | [`entities/puzzle.md`](../../design/entities/puzzle.md) |

## Style series

Primary series: [`SS1 — primary`](puzzle-pictures/style-series.md).

### SS1 — primary

N/A — the series fields and `prompt_policy` live in [`puzzle-pictures/style-series.md`](puzzle-pictures/style-series.md).

#### Prompt policy

N/A — the policy lives in [`puzzle-pictures/style-series.md`](puzzle-pictures/style-series.md).

## Recipes

N/A — the recipes live in [`puzzle-pictures/recipes.md`](puzzle-pictures/recipes.md).

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Size | Inspect | N×N colour cells (S1) |
| K2 | Fill band | Count | 25–45% of `size²`: 25–45 at 10×10, 56–101 at 15×15, 100–180 at 20×20 |
| K3 | Unique line-logic | Offline judge | Pass S4 |
| K4 | Colourful readable scene | Review | `prompt_policy` and the aesthetics pillar scope (picture content exempt from [`AES.P1`](../../aesthetics/aesthetics.md)); colourful multi-element complex scene with a real background, completely asymmetrical; reads at N×N; a sentence recorded, no class word |
| K5 | Pack look | Closing review | 200 approved V1 pairs, files resolve, regeneration record per size band (B1), variety (V2) judged on pictures |
| K6 | Both stored | Inspect | Square and N×N both catalogued |

## Naming

- **Handle name**: `puzzle-pictures/<puzzle-id>-generated` and `puzzle-pictures/<puzzle-id>-pixel`
- **Path**: under `game/assets/` from handle ([ADR-0003](../../adr/decisions/0003-catalog-asset-roots.md))
