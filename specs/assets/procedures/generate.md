# Asset Generate

Authoring rules: [`.agents/specs/rules/assets/procedures.md`](../../../.agents/specs/rules/assets/procedures.md).

Part of [`procedures.md`](../procedures.md).

## `APR.generate`

- **Trigger**: a coverage rule needs an asset the catalog lacks.
- **Inputs**: kind spec, coverage rule, recipe with realized tool role, style series (if any), style anchors.

1. If the kind Style series is `active`, require its style binding for the modality and use the series prompt template. Hard: visual needs `recraft_style_id`; music needs `elevenlabs_finetune_id`; voice needs `elevenlabs_voice_id`. Soft (SFX): anchors + `prompt_policy` only. If `none` or `bootstrapping`, only bootstrap seed runs (bootstrap template); do not full-series generate.
2. Add a draft entry with a new asset ID per [`catalog.md`](../catalog.md).
3. Fill the recipe template from coverage slots; compose with Style series `prompt_policy` (master + negative). Pass the modality binding when `active` and hard (`input_style_id` / `finetune_id` / `voice_id`). For music, attach Audio Reference when the series policy is `required` or the recipe requests `optional`. Run through the tool role (Recraft visual / ElevenLabs CLI audio when series-active).
4. Post-process; save files per the kind's naming. Run kind checks; retry within the limit in [`procedures.md`](../procedures.md).
5. Record structured `generation` (prompt, negatives, tool, operation, settings, inputs, series copy, steps). Run `APR.review`.
