---
name: establish-asset-style
description: |-
  Establish or refresh a kind's Style series: bootstrap approved style
  anchors, create the modality binding (Recraft style for visual;
  ElevenLabs finetune for music, voice id for voice; soft anchors for
  SFX), write the kind registry (binding, prompt_policy, state active),
  and open a PR. Identity needs enforced styling, master/negative
  prompting, and review (look or listen). Recraft is required for
  visual series; ElevenLabs CLI for music/SFX/voice (docs/asset-tools.md).
  Use when starting a kind's consistent generation, after anchors change,
  when the series is stale, or the user asks to create/refresh the style
  for sprites, tiles, music, SFX, or voice.

  Examples:
    - user: "Set up the character-sprite style series" → APR.establish-style (Recraft)
    - user: "Establish the battle-music finetune from these anchors" → music series
    - user: "Refresh the tile style after new anchors" → recreate binding, update SS1
---

# Establish asset style

Veneer over [`APR.establish-style`](../../../specs/assets/procedures/establish-style.md). Tools: [`docs/asset-tools.md`](../../../docs/asset-tools.md). Do not restate the modality table or registry fields.

## Steps

1. **Gate**. Stop and offer `author-spec` or `capture-requirements` when the kind Style series or cited aesthetics hold TBD, or the modality tool is unavailable and no person can run the binding step (Recraft `create_style`; ElevenLabs CLI finetune or voice clone — `elevenlabs` on PATH, `ELEVENLABS_API_KEY` in the environment).
2. **Start** per [`../manage-asset/references/change-pr.md`](../manage-asset/references/change-pr.md) (before editing).
3. **Run** `APR.establish-style` as written. Bootstrap seeds through [`manage-asset`](../manage-asset/SKILL.md) or [`register-asset`](../register-asset/SKILL.md). Require [`review-asset`](../review-asset/SKILL.md) Pass, or a person exemption, before the user confirms anchors.
4. **PR** per [`../manage-asset/references/change-pr.md`](../manage-asset/references/change-pr.md) (after editing). Apply the PoC ask when the run is for a PoC under `pocs/`. Authority cites the kind Style series and aesthetics IDs. Test plan: anchors Pass, binding created or soft-affirmed, kind registry updated.

## Rules

- Recraft is required for visual establish. ElevenLabs CLI is required for music, SFX, and voice ([`docs/asset-tools-elevenlabs.md`](../../../docs/asset-tools-elevenlabs.md)). Do not substitute fal, Cheaper Inference, or an ElevenLabs MCP.
- Do not invent anchors, `prompt_policy` clauses, or aesthetics IDs. Missing ones go to specs first.
- Establishing the series does not approve series members.
- Credentials never enter the repository.
