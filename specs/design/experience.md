# Experience and Feel

Authoring rules: [`.agents/specs/rules/design/experience.md`](../../.agents/specs/rules/design/experience.md).

## Experience goals

| Vision quality | Moment the player feels it | How the design produces it |
|----------------|----------------------------|----------------------------|
| Calm tactile grid | Each fill, cross, or clear | Cell marks; uncluttered board ([`entities/cell.md`](entities/cell.md)) |
| Snappy solve | Mark lands at once; picture completes | [`loops/solve.md`](loops/solve.md); frame-time in quality |
| Cool clinical look | Gallery and board stay cool, not cute | Sensory intent → aesthetics |

## Pacing

- **Session arc**: Gallery → pick any puzzle → get-set-ready → mark until solved → the solved moment: fills become the stored pixel picture, then the stored generated picture → gallery; or leave to gallery. Often one puzzle or a few, then stop.
- **Rhythm**: Quiet deduction; light release on clue dim and on solve (BGM sting + solve image fade). No fail pressure.
- **Durations**: One mark = instant; each morph stage is [`CFG.MORPH_STAGE_MS`](configuration.md) (default 300 ms); one puzzle = minutes; session = one puzzle or a few.

## Feedback principles

| Event | Player must understand | Priority |
|-------|------------------------|----------|
| Mark applied | Cell is clear, fill, or cross | high |
| Line error | This row/col’s fills contradict its clues | high |
| Clue satisfied | That line’s runs are realized (dim) | medium |
| Solved | Picture complete; ever-completed set; personal best updates when the solve is shorter | high |
| Gallery progress | Attempt status, ever-completed, personal best, completion rate | medium |
| Get-set-ready | Marks not allowed yet | medium |

## Sensory intent

- **Mood and style**: Cool, clinical, high-contrast, quiet focus — not warm, cute, or playful.
- **Sound intent**: Light calm BGM during play; soft distinct ticks for fill, cross, and clear under it. On solve, a calm-yet-triumphant sting over the continuing bed. Concrete audio → aesthetics / view.
- **Clarity rules**: Fill, cross, and clear always distinct; clues readable; line error is contradiction, not fail; solution hidden on the board while solving. After solve, fills fade into the stored pixel picture, then into the stored generated picture (fills only); then return to gallery. Gallery thumbnail remains the lasting picture after ever-completed.

## Accessibility

- **Channels**: N/A — accessibility is N/A in [`quality.md`](../definition/quality.md) (personal/simple product; no store a11y mandate).
- **Timing and assists**: N/A — same reason.
- **Scale**: N/A — same reason.

## Localization

- N/A — English-only UI.

## Learning and mastery

Learn by marking: clues define groups; crosses are optional; line error teaches contradiction; no forced tutorial campaign. Mastery is faster clean solves and better personal bests.

## Experiences to avoid

- Punishing mistakes with fail, lives, or lockouts.
- Cute or noisy chrome that muddies the grid.
- Live per-cell “wrong” while marking.
- Forced puzzle order.
- Requiring crosses to win.
