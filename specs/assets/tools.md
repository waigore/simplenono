# Asset Tools

Authoring rules: [`.agents/specs/rules/assets/tools.md`](../../.agents/specs/rules/assets/tools.md).

## Tool roles

| ID | Role | Source type | Kinds served | Required capabilities | Realized by |
|----|------|-------------|--------------|-----------------------|-------------|
| <!-- fill in --> | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |

## Access

| Role | Access | Run by | Cost or quota limit |
|------|--------|--------|---------------------|
| <!-- fill in --> | <!-- fill in --> | <!-- fill in --> | <!-- fill in --> |

Credentials never enter the repository.

## Constraints on ADR

Every role a recipe uses needs an Accepted Integration ADR that realizes all of its required capabilities, **or** realization by a tool that [`docs/asset-tools.md`](../../docs/asset-tools.md) marks ADR-free (today: Recraft for visual style series and preferred visual design; Cheaper Inference for non-series visual generate / reference-anchor; Poly Haven for third-party texture/model catalog import; ElevenLabs CLI for music / SFX / voice). Until then the role is Pending and its recipes do not run. An ADR that changes a role reopens every recipe that uses it for review.

Style-series establish and style-constrained generate require the modality style-binding capability: visual → Recraft; music / SFX / voice → ElevenLabs CLI (both ADR-free) per that doc. Cheaper Inference and Poly Haven must not realize those capabilities. Touch-ups ([`APR.touch-up`](procedures/touch-up.md)) are not tool roles and need no ADR. No role is realized by a tool that [`docs/asset-tools.md`](../../docs/asset-tools.md) bans.
