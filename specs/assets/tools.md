# Asset Tools

Authoring rules: [`.agents/specs/rules/assets/tools.md`](../../.agents/specs/rules/assets/tools.md).

## Tool roles

| ID | Role | Source type | Kinds served | Required capabilities | Realized by |
|----|------|-------------|--------------|-----------------------|-------------|
| TL.1 | Full-colour image generate (non-series) | AI generation | [`puzzle-pictures`](kinds/puzzle-pictures.md) | Square canvas; default model `flux-2-max`; no Recraft style id | ADR-free — Cheaper Inference per [`docs/asset-tools.md`](../../docs/asset-tools.md) |
| TL.2 | Offline image→nonogram derive | Procedural / local tooling | [`puzzle-pictures`](kinds/puzzle-pictures.md) | Keep the square generate; pixelate a copy 1:1; luma fill band; uniqueness + line-logic judge; regenerate-on-fail | Local authoring/CI scripts (not in-game) |
| TL.3 | Mark-tick SFX generate | AI generation | [`sfx`](kinds/sfx.md) | Soft synthesized fill/cross/clear ticks; duration and loudness per kind | ADR-free — ElevenLabs CLI per [`docs/asset-tools.md`](../../docs/asset-tools.md) |
| TL.4 | Bed and sting music generate | AI generation | [`music`](kinds/music.md) | Looping bed; 1 s sting; tempo and loudness per kind; finetune when series `active` | ADR-free — ElevenLabs CLI per [`docs/asset-tools.md`](../../docs/asset-tools.md) |

## Access

| Role | Access | Run by | Cost or quota limit |
|------|--------|--------|---------------------|
| TL.1 | REST with `CHEAPERINFERENCE_API_KEY` in the environment | agent or person | Prefer batch quotas; discard failed judges |
| TL.2 | Repository scripts / CI offline | agent or person | None |
| TL.3 | CLI with `ELEVENLABS_API_KEY` in the environment | agent or person | Prefer short generates; discard failed listen checks |
| TL.4 | CLI with `ELEVENLABS_API_KEY` in the environment | agent or person | Prefer short stems; discard failed listen checks |

Credentials never enter the repository.

## Constraints on ADR

Every role a recipe uses needs an Accepted Integration ADR that realizes all of its required capabilities, **or** realization by a tool that [`docs/asset-tools.md`](../../docs/asset-tools.md) marks ADR-free (today: Recraft for visual style series and preferred visual design; Cheaper Inference for non-series visual generate / reference-anchor; Poly Haven for third-party texture/model catalog import; ElevenLabs CLI for music / SFX / voice). Until then the role is Pending and its recipes do not run. An ADR that changes a role reopens every recipe that uses it for review.

**Project exception — puzzle pictures**: this kind does **not** use a Recraft visual style series. TL.1 is Cheaper Inference `flux-2-max` only ([`kinds/puzzle-pictures.md`](kinds/puzzle-pictures.md) SS1). Style-series establish / style-constrained generate for other visual kinds still require Recraft per that doc. Cheaper Inference and Poly Haven must not realize Recraft style-binding capabilities. Touch-ups ([`APR.touch-up`](procedures/touch-up.md)) are not tool roles and need no ADR. No role is realized by a tool that [`docs/asset-tools.md`](../../docs/asset-tools.md) bans.
