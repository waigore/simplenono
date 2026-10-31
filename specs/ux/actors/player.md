# Actor: Player

Authoring rules: [`.agents/specs/rules/ux/actors.md`](../../../.agents/specs/rules/ux/actors.md).

- **Serves**: Casual puzzle players ([`specs/vision.md`](../../vision.md)); Calm tactile grid, Snappy solve, Cool clinical look; local free-order pack on all supported platforms ([`specs/definition/definition.md`](../../definition/definition.md))
- **Platforms**: Windows, macOS, Linux, iOS, Android
- **Glossary terms**: [Player](../glossary.md)

## Who they are

The person playing for themselves in short sessions—someone who knows or will learn nonograms ([vision audience](../../vision.md)). Sole operator of the product; there is no co-player or spectator actor.

## Goals

- Pick any puzzle and solve it from the clues
- Improve a personal best when they choose to replay
- See pack progress (completion rate and statuses)
- Leave an attempt and resume an in-progress board later
- Adjust haptics and mute in slim settings

## Can operate

- **C1**: Gallery — browse the pack, open a puzzle, reset a puzzle, open settings ([`screens/gallery.md`](../screens/gallery.md))
- **C2**: Puzzle — mark while allowed; Fill / Cross / Clear; leave or pause into settings ([`screens/puzzle.md`](../screens/puzzle.md))
- **C3**: Result — see the fill→image morph; return to gallery ([`screens/result.md`](../screens/result.md))
- **C4**: Settings — change haptics on/off and mute BGM; return to gallery or resume a paused puzzle ([`screens/settings.md`](../screens/settings.md))

## Cannot operate

- **K1**: Pack editor or online-account UI — no such controls exist (out of scope in definition)

## Relationship to play

None — no design character. The actor marks the board directly.
