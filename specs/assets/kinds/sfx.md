# Asset Kind: Sound effects

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Sound effects
- **Source types**: AI generation; Human-made (`register-asset`)
- **Style**: Snappy restraint ([`AES.P3`](../../aesthetics/aesthetics.md)); mark ticks ([`SND.X1`](../../aesthetics/sound.md)–[`X3`](../../aesthetics/sound.md), [`SND.L2`](../../aesthetics/sound.md))
- **Tool roles**: [`TL.3`](../tools.md)
- **Approval**: As hub
- **Serves**: Mark-applied feedback ([`experience.md`](../../design/experience.md); [`ACC.G1`](../access.md))

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Fill apply | Soft fill tick | 1 |
| V2 | Cross apply | Soft cross tick | 1 |
| V3 | Clear apply | Soft clear tick | 1 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Character | Soft synthesized; fill / cross / clear distinct ([`SND.X1`](../../aesthetics/sound.md)–[`X3`](../../aesthetics/sound.md)) |
| S2 | Duration | 40–120 ms |
| S3 | Loudness | −32 LUFS ([`SND.L2`](../../aesthetics/sound.md)) |
| S4 | Loop | No |
| S5 | Mute | Audible when BGM is muted ([`sound.md`](../../aesthetics/sound.md)) |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Duration | 40–120 ms | [`SND.X1`](../../aesthetics/sound.md)–[`X3`](../../aesthetics/sound.md); hitch-bound |
| B2 | Kind count | One tick per mark tool | [`AES.P3`](../../aesthetics/aesthetics.md) |

## Style series

### SS1 — primary

- **State**: none
- **Modality**: sfx
- **Enforce**: soft
- **Style anchors**: None yet
- **Style binding**: None — soft SFX ([`docs/asset-tools-elevenlabs.md`](../../../docs/asset-tools-elevenlabs.md))
- **Aesthetics**: [`AES.P3`](../../aesthetics/aesthetics.md); [`SND.X1`](../../aesthetics/sound.md)–[`X3`](../../aesthetics/sound.md); [`SND.L2`](../../aesthetics/sound.md)
- **Built from**: None
- **Refresh when**: aesthetics sound change or review Fail

#### Prompt policy

- **Compose**: subject-first when generating; append master + negative
- **Master**: very soft short synthesized clinical UI tick; gentle; not musical; tool-distinct
- **Negative**: long tails; loud hits; sharp clicks; cartoon boings; voice

## Recipes

### R1 — ElevenLabs mark ticks

- **Source type**: AI generation
- **Tool role**: TL.3
- **Inputs**: Tool (fill|cross|clear); duration and loudness (S2, S3)
- **Prompt template (bootstrap)**: very soft clinical {fill\|cross\|clear} tick {ms}; compose with `prompt_policy`
- **Prompt template (series)**: N/A — SS1 `none`
- **Settings**: ElevenLabs CLI sound-effects; trim to S2; normalize to S3
- **Seed policy**: n/a — tool has no seed
- **Post-processing**: Trim silence; soft fades; loudness to −32 LUFS
- **Outputs**: Three catalogued ticks under the asset root

### R2 — Person-supplied ticks

- **Source type**: Human-made
- **Tool role**: N/A — `register-asset`
- **Inputs**: Person-owned files meeting S1–S5
- **Prompt template (bootstrap)**: N/A — human-made
- **Prompt template (series)**: N/A — human-made
- **Settings**: N/A — human-made
- **Seed policy**: N/A — human-made
- **Post-processing**: Same as R1
- **Outputs**: Same as R1

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Duration | Measure | S2 |
| K2 | Loudness | Measure | S3 |
| K3 | Character | Listen review | S1; prompt_policy; tools distinguishable |
| K4 | Three ticks | Inspect | V1–V3 / B2 |

## Naming

- **Handle name**: `sfx/fill-tick`, `sfx/cross-tick`, `sfx/clear-tick`
- **Path**: under `game/assets/` from handle ([ADR-0003](../../adr/decisions/0003-catalog-asset-roots.md))
