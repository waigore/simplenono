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

# Establish asset style (facade)

Canonical instructions: [`.agents/skills/establish-asset-style/SKILL.md`](../../../.agents/skills/establish-asset-style/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
