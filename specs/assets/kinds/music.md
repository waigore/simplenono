# Asset Kind: Music

Authoring rules: [`.agents/specs/rules/assets/kinds.md`](../../../.agents/specs/rules/assets/kinds.md).

- **Kind**: Music
- **Source types**: AI generation; Human-made (`register-asset`)
- **Style**: [`AES.P1`](../../aesthetics/aesthetics.md), [`AES.P3`](../../aesthetics/aesthetics.md); [`SND.M1`](../../aesthetics/sound.md)/[`M2`](../../aesthetics/sound.md), [`SND.L1`](../../aesthetics/sound.md)/[`L3`](../../aesthetics/sound.md)
- **Tool roles**: [`TL.4`](../tools.md)
- **Approval**: As hub
- **Serves**: Quiet focus and solve sting ([`sound.md`](../../aesthetics/sound.md); [`ACC.G2`](../access.md))

## Coverage

| ID | Subject | Required variants | Count |
|----|---------|-------------------|-------|
| V1 | Gallery / puzzle bed | Looping bed ([`SND.M1`](../../aesthetics/sound.md)) | 1 |
| V2 | Solve sting | 1 s over bed ([`SND.M2`](../../aesthetics/sound.md)) | 1 |

## Specification

| ID | Property | Value |
|----|----------|-------|
| S1 | Bed | Soft synth + quiet mallet; no percussion; 60–80 BPM; light calm |
| S2 | Sting | Same instruments; calm triumphant; 1 s |
| S3 | Bed loudness | −23 LUFS ([`SND.L1`](../../aesthetics/sound.md)); seamless loop |
| S4 | Sting loudness | −18 LUFS ([`SND.L3`](../../aesthetics/sound.md)); bed continues |

## Budgets

| ID | Limit | Value | Traces to |
|----|-------|-------|-----------|
| B1 | Sting length | 1 s | [`SND.M2`](../../aesthetics/sound.md) |
| B2 | Kind count | One bed + one sting | [`ACC.G2`](../access.md) |

## Style series

### SS1 — primary

- **State**: none
- **Modality**: music
- **Enforce**: hard once finetune exists; soft while `none`
- **Style anchors**: None yet
- **Style binding**: ElevenLabs finetune when `active`; Audio Reference `optional`
- **Aesthetics**: AES.P1, AES.P3; SND.M1/M2
- **Built from**: None
- **Refresh when**: sound aesthetics, anchors, or review Fail

#### Prompt policy

- **Compose**: subject-first; append master + negative
- **Master**: soft synth + quiet mallet; 60–80 BPM; calm bed or calm triumphant 1 s sting
- **Negative**: percussion hits; voice; aggressive EDM; cozy whimsy

## Recipes

### R1 — ElevenLabs bed and sting

- **Source type**: AI generation
- **Tool role**: TL.4
- **Inputs**: M1 vs M2 brief; loudness targets
- **Prompt template (bootstrap)**: clinical {bed\|sting}; compose with `prompt_policy`
- **Prompt template (series)**: N/A — SS1 `none` until finetune
- **Settings**: ElevenLabs CLI; loop bed; sting ≤1 s; normalize S3/S4
- **Seed policy**: n/a — tool has no seed
- **Post-processing**: Loudness; seamless loop; trim sting to 1 s
- **Outputs**: Catalogued bed and sting

### R2 — Person-supplied

- **Source type**: Human-made
- **Tool role**: N/A — `register-asset`
- **Inputs**: Person-owned file meeting S-rows
- **Prompt template (bootstrap)**: N/A — human-made
- **Prompt template (series)**: N/A — human-made
- **Settings**: N/A — human-made
- **Seed policy**: N/A — human-made
- **Post-processing**: Same as R1
- **Outputs**: Same roles as R1

## Checks

| ID | Check | Method | Pass criterion |
|----|-------|--------|----------------|
| K1 | Bed / sting character | Listen | S1–S2 |
| K2 | Loudness / loop / length | Measure | S3, S4, B1 |
| K3 | Style calm | Listen | prompt_policy; AES.P1/P3 |

## Naming

- **Handle name**: `music/bed`, `music/solve-sting`
- **Path**: under `game/assets/` from handle ([ADR-0003](../../adr/decisions/0003-catalog-asset-roots.md))
