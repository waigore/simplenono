# Establish Style Series

Authoring rules: [`.agents/specs/rules/assets/procedures.md`](../../../.agents/specs/rules/assets/procedures.md).

Part of [`procedures.md`](../procedures.md). Skill: `establish-asset-style`.

## `APR.establish-style`

- **Trigger**: a kind’s Style series is `none`, `bootstrapping`, or `stale`, and the project needs an `active` series for consistent generation.
- **Inputs**: the kind spec (Style series + recipes), cited aesthetics / `REF`s, approved or seed assets, modality tool per [`docs/asset-tools.md`](../../../docs/asset-tools.md) (Recraft for visual; ElevenLabs CLI for music / SFX / voice).
- **Pillars**: enforced styling, master/negative `prompt_policy`, review (look or listen) — all three required for identity.

1. Gate: Style series and cited aesthetics hold no undecided placeholders. Confirm **modality** and **enforce**. Set state `bootstrapping` if `none`.
2. If `style_anchors` is empty: bootstrap seed assets via `APR.generate` (bootstrap prompt template + `prompt_policy`) or `APR.register` / human supply; run checks and `APR.review`. Stop until Pass and the user confirms which approved IDs are anchors.
3. Confirm tool terms fit the definition. Create the modality binding:
   - **visual (hard)**: upload anchors; Recraft `create_style`; store `recraft_style_id` + model/base.
   - **music (hard)**: upload anchors; create Music Finetune via the ElevenLabs CLI; store `elevenlabs_finetune_id` + model; set Audio Reference policy.
   - **voice (hard)**: clone or select voice from anchors via the ElevenLabs CLI; store `elevenlabs_voice_id`.
   - **sfx (soft)**: no product style id; record anchors only. Soft enforce stays until a durable binding exists.
4. Write the kind Style series registry: modality, enforce, `style_anchors`, style binding, `built_from` (anchor IDs + date), `aesthetics` cites, `prompt_policy` if still a fill-in. Set state `active`.
5. On refresh (`stale`): recreate binding from current anchors; replace the stored id (or reaffirm soft anchors); do not keep an old hard id silently. Re-review assets that cited the old id via `APR.update` as needed.

**Outputs**: updated kind Style series section; optional new catalog entries for seeds.
