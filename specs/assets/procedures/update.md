# Asset Update

Authoring rules: [`.agents/specs/rules/assets/procedures.md`](../../../.agents/specs/rules/assets/procedures.md).

Part of [`procedures.md`](../procedures.md).

## `APR.update`

- **Trigger**: a fail, changed aesthetics/recipe/tool role/style series, or a request.

1. Keep the asset ID; raise version; record the reason. Append `history` with the prior generation (and touch-ups added) before overwrite.
2. Prefer the prior prompt as a guide; keep series style when `active` (Recraft or ElevenLabs CLI per modality). Regenerate or edit per recipe; audio re-runs mix post-process to `SND.L`. Checks and `APR.review`.
3. Re-check assets built from this one.
