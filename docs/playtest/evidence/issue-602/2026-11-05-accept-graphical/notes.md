# Notes — issue #602 graphical acceptance (`PTD-clue-dim`)

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
   be the expected `INK` / `DIM` / `CONTRADICTION` colour, so a correct colour override
   that never reaches the screen fails.

## Result

The rule and the colour model are correct everywhere they were judged; the **drawn row
clue is not**. Every row clue `Label` is laid out **1 px wide** at `cell = 40`
(`get_global_rect()` reads `S: (1.0, 26.0)`), and `_make_clue_label` sets `clip_text =
true` with no minimum width, so the glyph is clipped away. The whole row clue bar holds
no glyph pixel in all eight screenshots, while column clues draw and dim correctly.

Captured failures (all the same cause):

```
capture: FAIL S2/P1: row 8 `1 4`, one fill: number 0 is laid out 1 px wide in its clue bar, so its glyph is clipped and not drawn
capture: FAIL S2/P1: row 8 `1 4`, one fill: number 1 is laid out 1 px wide in its clue bar, so its glyph is clipped and not drawn
capture: FAIL S3/P2: row 7 `3`, exactly filled: number 0 is laid out 1 px wide in its clue bar, so its glyph is clipped and not drawn
capture: FAIL S3/P2: row 7 `3`, island of two after the clear: number 0 is laid out 1 px wide in its clue bar, so its glyph is clipped and not drawn
capture: FAIL P1/I2: row 8 `1 4`, island `1` matches: number 0 is laid out 1 px wide in its clue bar, so its glyph is clipped and not drawn
capture: FAIL P1/I2: row 8 `1 4`, island `1` matches: number 1 is laid out 1 px wide in its clue bar, so its glyph is clipped and not drawn
capture: FAIL P1/I2: row 8 with its island of five: number 0 is laid out 1 px wide in its clue bar, so its glyph is clipped and not drawn
capture: FAIL P1/I2: row 8 with its island of five: number 1 is laid out 1 px wide in its clue bar, so its glyph is clipped and not drawn
capture: FAIL S2: row 7 `3`, two fills toward it: number 0 is laid out 1 px wide in its clue bar, so its glyph is clipped and not drawn
capture: FAIL S5/P4: row 6 `6 2`, exactly realized: number 0 is laid out 1 px wide in its clue bar, so its glyph is clipped and not drawn
capture: FAIL S5/P4: row 6 `6 2`, exactly realized: number 1 is laid out 1 px wide in its clue bar, so its glyph is clipped and not drawn
```

Filed as defect #619.

## First-draft corrections (kept for the record)

The first probe draft asserted that growing row 8's `1` island to two keeps the numbers
highlighted. The board instead reads `CONTRADICTION` on that line, and the rules are
right: `4` needs four fills with a clear before them, and the island of two leaves a
contiguous fill block with no room for the `1` — the line contradicts its clue. That
state is judged as the `E-clue` I4 precedence case (`03-error-over-dim`), and the
board-wide un-dim case (`PTD-clue-dim` P2) uses a clear inside a matched island on row
7 `3` with a completed column 5 `3 1` beside it instead.

## Harness caveats

- The host renders this frame under llvmpipe; the probe schedules judging by frames and
  waits two frames for containers to sort before sampling pixels.
- The reopen leg uses the gallery's own `activate_tile` entry point (the same one the
  shell's C1 routes through); the pointer path for a gallery tile is `PTU-gallery-layout`'s.
