# Sound Style

Authoring rules: [`.agents/specs/rules/aesthetics/sound.md`](../../.agents/specs/rules/aesthetics/sound.md).

- **Serves**: Quiet focus and snappy restraint ([`AES.P3`](aesthetics.md), [`experience.md`](../design/experience.md)). One non-spatial mix ([`audio.md`](../view/audio.md)). Music changes when the puzzle is solved ([`END.W1`](../design/end-conditions.md)).

## Music

| ID | Context | Genre and instrumentation | Tempo (BPM) | Mood |
|----|---------|---------------------------|-------------|------|
| M1 | Gallery and the open puzzle | Sparse soft synth and a quiet mallet; no percussion hits | 60–80 | Light and calm |
| M2 | On solve, a 1 s sting over M1 | Same instruments as M1 | 60–80 | Calm and triumphant |

The bed keeps playing under the sting ([`experience.md`](../design/experience.md)).

## Sound effects

| ID | Category | Character | Duration range |
|----|----------|-----------|----------------|
| X1 | interface | synthesized | 40–120 ms |

One tick for a fill, a cross, or a clear. It carries the mark-applied feedback ([`experience.md`](../design/experience.md)). Clue dim and line error stay visual.

## Voice

N/A — no speaker and no spoken lines ([`experience.md`](../design/experience.md), [`view.md`](../view/view.md)).

## Mix

| ID | Category | Target loudness | Relation to other categories |
|----|----------|-----------------|------------------------------|
| L1 | Music bed | -23 LUFS integrated | Stays under the sting; no ducking |
| L2 | Mark tick | -28 LUFS | Quieter than the bed; no ducking |
| L3 | Solve sting | -18 LUFS | In front of the bed for 1 s; the bed continues |

No positional mix ([`audio.md`](../view/audio.md)).
