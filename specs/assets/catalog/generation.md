# Generation Record Shape

Authoring rules: [`.agents/specs/rules/assets/catalog.md`](../../../.agents/specs/rules/assets/catalog.md).

Part of [`fields.md`](fields.md) (`CAT.F11`).

Agent-generated `generation` object parts:

| Part | Meaning |
|------|---------|
| `prompt` | Prompt as run (after composing recipe template + `prompt_policy`) |
| `negative_prompt` | Source negative clauses when composed |
| `tool` | Product name (e.g. Recraft, ElevenLabs) |
| `operation` | MCP operation name |
| `settings` | At least `model` when used; size/aspect for images; duration/loudness for audio; hard binding when series-active: `input_style_id` (visual), `finetune_id` (music), `voice_id` (voice); music may include audio-reference metadata |
| `seed` | Value, or `n/a — tool has no seed` |
| `inputs` | `style_anchors`, `refs`, `base_assets` |
| `series` | Copy from the kind registry when used: always `id`; plus exactly one of `recraft_style_id`, `elevenlabs_finetune_id`, `elevenlabs_voice_id`, or `soft_enforce: true` (SFX) |
| `steps` | Ordered tool calls for this version |

Person-supplied generated assets: record the tool and whatever of these the person can supply.
