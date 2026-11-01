# Asset Kind: Fonts

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Fonts
- **Source types**: Third-party; Human-made (`register-asset`)
- **Style**: Cool clinical look ([`AES.P1`](../../aesthetics/aesthetics.md)); grid clarity ([`AES.P2`](../../aesthetics/aesthetics.md)); snappy restraint ([`AES.P3`](../../aesthetics/aesthetics.md)); [`UIS.T1`](../../aesthetics/ui-style.md) / [`UIS.T2`](../../aesthetics/ui-style.md)
- **Tool roles**: None — import / register only
- **Approval**: As hub
- **Serves**: Readable clues and chrome ([`ui-style.md`](../../aesthetics/ui-style.md); [`ACC.G1`](../access.md))

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Pack UI type | One geometric sans family for T1 clues and T2 chrome | 1 family |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Classification | Geometric sans |
| S2 | Weight | Regular for T1 and T2 |
| S3 | Figures | Tabular figures for clues and personal-best time |
| S4 | Case | Sentence case for chrome words ([`UIS.T2`](../../aesthetics/ui-style.md)) |
| S5 | Formats | Engine-loadable under Godot (e.g. `.ttf` / `.otf`) |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Kind count | One family for the whole UI | [`AES.P3`](../../aesthetics/aesthetics.md); [`ACC.G1`](../access.md) |

## Style series

### SS1 — primary

- **State**: none
- **Modality**: visual
- **Enforce**: soft
- **Style anchors**: None yet
- **Style binding**: None — third-party / human; no Recraft series
- **Aesthetics**: [`AES.P1`](../../aesthetics/aesthetics.md)–[`P3`](../../aesthetics/aesthetics.md); [`UIS.T1`](../../aesthetics/ui-style.md)/[`T2`](../../aesthetics/ui-style.md)
- **Built from**: None
- **Refresh when**: aesthetics type roles change or review Fail

#### Prompt policy

- **Compose**: N/A — no AI generate for this kind
- **Master**: N/A — no AI generate for this kind
- **Negative**: N/A — cute or display faces are rejected at review

## Recipes

### R1 — Licensed geometric sans

- **Source type**: Third-party
- **Tool role**: N/A — human-made / register
- **Inputs**: License terms fitting definition market constraints
- **Prompt template (bootstrap)**: N/A — third-party import
- **Prompt template (series)**: N/A — third-party import
- **Settings**: N/A — third-party import
- **Seed policy**: N/A — human-made
- **Post-processing**: Subset if needed; keep tabular figures
- **Outputs**: One catalogued font family under the asset root

### R2 — Person-supplied face

- **Source type**: Human-made
- **Tool role**: N/A — `register-asset`
- **Inputs**: Person-owned or licensed files
- **Prompt template (bootstrap)**: N/A — human-made
- **Prompt template (series)**: N/A — human-made
- **Settings**: N/A — human-made
- **Seed policy**: N/A — human-made
- **Post-processing**: Same as R1
- **Outputs**: Same as R1

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Geometric sans | Review | S1 |
| K2 | Tabular figures | Inspect | S3 |
| K3 | T1/T2 coverage | Review | One family serves both roles (V1) |
| K4 | Clinical fit | Review | AES.P1–P3; not playful display |

## Naming

- **Handle name**: `fonts/<family-kebab>`
- **Path**: under `game/assets/` from handle ([ADR-0003](../../adr/decisions/0003-catalog-asset-roots.md))
