# Recipes: Puzzle pictures

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../../.agents/specs/rules/assets/kinds.md). Kind summary: [`puzzle-pictures.md`](../puzzle-pictures.md).

## Coverage

N/A — coverage stays in the kind summary ([`puzzle-pictures.md`](../puzzle-pictures.md)).

## Specification

N/A — the specification stays in the kind summary ([`puzzle-pictures.md`](../puzzle-pictures.md)).

## Budgets

N/A — the budget stays in the kind summary ([`puzzle-pictures.md`](../puzzle-pictures.md)).

## Style series

N/A — the style series lives in [`puzzle-pictures/style-series.md`](style-series.md).

### SS1 — primary

N/A — see [`puzzle-pictures/style-series.md`](style-series.md).

#### Prompt policy

N/A — see [`puzzle-pictures/style-series.md`](style-series.md).

## Recipes

### R1 — Flux → nonogram (offline)

- **Source type**: AI generation
- **Tool role**: TL.1 then TL.2
- **Inputs**: size N; subject prompt (V1)
- **Prompt template (bootstrap)**: colourful multi-element scene of {subject} with a real background, completely asymmetrical; compose with `prompt_policy`
- **Prompt template (series)**: N/A — SS1 `none`
- **Settings**: `flux-2-max`; keep square; BOX copy (S6)
- **Seed policy**: n/a — no seed
- **Post-processing**: haze/vignette artifact cleanup; luma (S2); no hole-close; line-logic (S4); else new prompt
- **Outputs**: both catalogued pictures, pack fill/clues

## Checks

N/A — the checks stay in the kind summary ([`puzzle-pictures.md`](../puzzle-pictures.md)).

## Naming

N/A — naming stays in the kind summary ([`puzzle-pictures.md`](../puzzle-pictures.md)).
