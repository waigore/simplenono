# Notes — issue #619 graphical acceptance (`PTD-clue-dim`)

## What was judged

The probe opens `pack-000` through `DBG.3` (`DebugSeams.open_puzzle` → `CTR-attempt` O1),
finishes the get-set-ready beat through the screen's own `finish_ready_beat()`, and then
marks cells with **real pointer events** (`Input.parse_input_event`, left button = fill,
right = complement cross), the same path `MarkInput` reads. After each mark it reads:

1. the expected island walk from the marks (`_island_lengths`: maximal runs of fills, a
   clear and a cross both end one) against each line's clue, drawn independently of
   `Rules._number_matches`;
2. each clue label's `font_color` against that expectation (with line error taking
   precedence), for the judged line and, through `_judge_board`, for all 20 lines;
3. the **drawn frame**: the darkest non-Paper pixel inside each label's global rect must
   be the expected `INK` / `DIM` / `CONTRADICTION` colour, and the label must be laid out
   wider than 8 px, so a correct colour override that never reaches the screen fails.

## Result

`capture: RESULT pass (8 shots, 0 checks failed)`, 42 `capture: PASS` checks, exit 0, no
script errors. The row clue bar draws its numbers: PR #625 gives each row clue label a
`custom_minimum_size.x` equal to its measured glyph width, so the `clip_text` label is no
longer collapsed to 1 px by the row `HBoxContainer`.

Judged states, all drawn:

- row 8 `1 4` with one fill: `1` dim, `4` highlighted; column 0 `1 1` likewise;
- row 7 `3` exactly filled then cleared to two: the number returns to highlighted while
  column 5 `3 1` stays dimmed (whole-board re-evaluation);
- row 8 with an island of five: `CONTRADICTION` on both numbers, error over dim;
- row 7 `3` with two fills: incomplete island stays highlighted, no line error;
- column 6 `3 2`: island of three dims only `3`; after a cross and two more fills both dim;
- row 6 `6 2` exactly realized: both dim;
- rows 0–1 (no clue): one empty glyph, dim;
- the cue after C1 leave and the gallery tile reopen.

## Comparison with the failing run

The first #602 acceptance run (`docs/playtest/evidence/issue-602/2026-11-05-accept-graphical`,
build `e097308`) failed 11 row-glyph checks: every row clue label was laid out 1 px wide
and clipped away (this defect). The same probe on this build passes all of them, so the
defect's fix is confirmed on the drawn frame.

## Harness caveats

- The host renders this frame under llvmpipe; the probe schedules judging by frames and
  waits two frames for containers to sort before sampling pixels.
- The reopen leg uses the gallery's own `activate_tile` entry point (the same one the
  shell's C1 routes through); the pointer path for a gallery tile is `PTU-gallery-layout`'s.
- The project was imported once (`godot --headless --import`) under the run's fresh `HOME`
  before the graphical run, so the global class cache existed for the probe.
