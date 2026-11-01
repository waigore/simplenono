# Asset tools

Known tools for image and audio generation, editing, and touch-up, and the tools this project bans. Specs stay product-neutral: most generation tools realize a tool role in [`specs/assets/tools.md`](../specs/assets/tools.md) through an Accepted Integration ADR. Tools this file marks **ADR-free**, and touch-up options, need no ADR. Touch-ups run through `APR.touch-up` ([`specs/assets/procedures/touch-up.md`](../specs/assets/procedures/touch-up.md)).

**Style series lock**: visual kinds require **Recraft**; music, SFX, and voice kinds require the **ElevenLabs CLI**. Project kind exceptions (e.g. simplenono `puzzle-pictures`) live in [`specs/assets/tools.md`](../specs/assets/tools.md).

## Banned tools

| Tool | Scope |
|------|-------|
| Pixellab | Never used for anything. Agents do not call it, even when its MCP server is connected. No Integration ADR may name it. `register-asset` refuses assets made or edited with it. CI rejects catalog entries whose generation or touch-up tool names it. |

## Preference

| Situation | Prefer |
|-----------|--------|
| Visual style establish (`create_style`) or style-constrained generate (`input_style_id`) | Recraft (required) |
| Audio style establish (finetune / voice) or style-constrained music/voice/SFX generate | ElevenLabs CLI (required) |
| Exploratory image work, editing, graphic design, vector art | Recraft |
| Default when Recraft can do the job | Recraft |
| High-throughput batch image generation (expect Recraft touch-up after); visual series not `active` | fal.ai or Cheaper Inference |
| Specific image model Recraft lacks; visual series not `active` | fal.ai or Cheaper Inference (default model `flux-2-max`) |
| OpenAI-compatible REST image gen/edit without MCP; visual series not `active` | Cheaper Inference |
| Free CC0 texture or model library (search + download) | Poly Haven |

## Generation and design

- **Recraft**: [`asset-tools-recraft.md`](asset-tools-recraft.md) (ADR-free; required for visual style series).
- **ElevenLabs**: [`asset-tools-elevenlabs.md`](asset-tools-elevenlabs.md) (ADR-free; CLI only; required for audio style series).
- **fal.ai**: [`asset-tools-fal.md`](asset-tools-fal.md) (needs Integration ADR; not for active style series).
- **Cheaper Inference**: [`asset-tools-cheaperinference.md`](asset-tools-cheaperinference.md) (ADR-free; REST; default `flux-2-max`; locked steps in [`asset-tools-cheaperinference-steps.md`](asset-tools-cheaperinference-steps.md); not for active style series).
- **Poly Haven**: [`asset-tools-polyhaven.md`](asset-tools-polyhaven.md) (ADR-free; REST; textures + models; locked steps in [`asset-tools-polyhaven-steps.md`](asset-tools-polyhaven-steps.md)).

## Pipelines

- **Textures** (select → land → tile check → optional touch-up → review): [`texture-pipeline.md`](texture-pipeline.md).

## Touch-up

A touch-up is an optional edit to an asset's files that brings it closer to its kind spec, aesthetics, or a quality target. It never replaces a recipe. Record in `touchups` (`CAT.F19`); source type and series binding stay. Recraft is the visual touch-up option ([`asset-tools-recraft.md`](asset-tools-recraft.md)). Audio post-steps (trim, loudness) stay in the kind recipe's post-processing unless a later tool doc adds an audio touch-up option. When a texture fails the tile/seam check, ask before Recraft seam work ([`texture-pipeline.md`](texture-pipeline.md)).

## Enabling tools

- **Recraft / fal**: MCP servers `recraft` and `fal` ship disabled. Enable locally per [`mcp.md`](mcp.md); use `setup-project-mcp`. Do not commit enabled state.
- **ElevenLabs**: CLI only ([`asset-tools-elevenlabs.md`](asset-tools-elevenlabs.md)). No MCP server. Assume `ELEVENLABS_API_KEY` is in the environment.
- **Cheaper Inference**: REST only ([`asset-tools-cheaperinference.md`](asset-tools-cheaperinference.md)). No MCP server. Assume `CHEAPERINFERENCE_API_KEY` is in the environment.
- **Poly Haven**: REST only ([`asset-tools-polyhaven.md`](asset-tools-polyhaven.md)). No MCP, no API key; send a project `User-Agent` on every request.
