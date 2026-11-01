# Configuration

Authoring rules: [`.agents/specs/rules/design/configuration.md`](../../.agents/specs/rules/design/configuration.md).

## Modes

| Mode | Description | Differs from standard rules by | Flow |
|------|-------------|--------------------------------|------|
| Standard | Free-order local pack play | Baseline | Gallery → puzzle → result ([`experience.md`](experience.md)) |

## Game options

| Option | Choices | Default | Effect on rules | Chosen by / when | Locked when |
|--------|---------|---------|-----------------|------------------|-------------|
| — | — | — | None — presentation prefs (haptics, mute BGM) are not rule variants; accessibility assists wait until quality Applies | — | — |

## Designer tunables

| Parameter | Owner spec | Default | Range | Unit | Effect |
|-----------|------------|---------|-------|------|--------|
| `CFG.GET_SET_READY_MS` | [`loops/solve.md`](loops/solve.md), [`progression.md`](progression.md) | 500 | 200–1500 | ms | How long marks stay blocked after a puzzle opens |
| `CFG.MORPH_STAGE_MS` | [`experience.md`](experience.md), [`motion.md`](../aesthetics/motion.md) | 300 | 100–800 | ms | Length of each result morph stage |

Pack size (200) is a progression fact ([`progression.md`](progression.md)), not a tunable.

## Dependencies and restrictions

- **K1**: None
