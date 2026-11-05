# Configuration

Authoring rules: [`.agents/specs/rules/design/configuration.md`](../../.agents/specs/rules/design/configuration.md).

## Modes

| Mode | Description | Differs from standard rules by | Flow |
|------|-------------|--------------------------------|------|
| Standard | Free-order local pack play | Baseline | Gallery → puzzle → result ([`experience.md`](experience.md)) |

## Game options

| Option | Choices | Default | Effect on rules | Chosen by / when | Locked when |
|--------|---------|---------|-----------------|------------------|-------------|
| Single-line fill hint | on / off | off | Optional assist distinct from clues: when on, single-line forced cells may show as overlays (not board marks). Enabling during an open attempt is observable so hint-free can void | Player, any time in settings | Never |
| Multi-line fill hint | on / off | off | Same assist class; one-level multi-line overlays only when on | Player, any time in settings | Never |
| Line-level fillable hint | on / off | off | Same assist class; when on, fill-tool taps may shade a max legal run | Player, any time in settings | Never |

Presentation prefs (haptics, mute BGM, orientation) are not rule variants. The overlay behaviour of the two fill hints is specified in [`features/fill-hints.md`](features/fill-hints.md); shade, hint-free earn/void behaviour are owned by their design/UX/technical specs; this table only locks the three persisted assist options and defaults.

## Designer tunables

| Parameter | Owner spec | Default | Range | Unit | Effect |
|-----------|------------|---------|-------|------|--------|
| `CFG.GET_SET_READY_MS` | [`loops/solve.md`](loops/solve.md), [`progression.md`](progression.md) | 500 | 200–1500 | ms | How long marks stay blocked after a puzzle opens |
| `CFG.MORPH_STAGE_MS` | [`experience.md`](experience.md), [`motion.md`](../aesthetics/motion.md) | 300 | 100–800 | ms | Length of each result morph stage |

Pack size (200) is a progression fact ([`progression.md`](progression.md)), not a tunable.

## Dependencies and restrictions

- **K1**: None
