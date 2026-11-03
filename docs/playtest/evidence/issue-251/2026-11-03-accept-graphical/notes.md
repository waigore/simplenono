# Notes — issue #251 acceptance playtest

## What was judged

The four slice rows (`pack-074`…`pack-077`) on `main@9053c8c`. Every fill the probe places is
a committed `solution-fills` cell, and the probe cross-checks each row's `solution-fills`
against `expect.json` (read independently from the committed `-pixel.png` with the issue's
fixed rule: alpha over white, `Y = 0.2126R + 0.7152G + 0.0722B`, filled below 128). A wrong
clue, a wrong fill set, or a pixel that disagrees with its row therefore shows up as "the
board will not finish" — none did.

| Puzzle | class (measured) | filled / 225 | judge | derive reproduces pixel |
|---|---|---|---|---|
| pack-074 | multi (masses 33, 27; 0 holes) | 60 | pass (1 solution, line logic) | byte-identical |
| pack-075 | multi (masses 44, 35; 0 holes) | 79 | pass | byte-identical |
| pack-076 | multi (masses 40, 21; 0 holes) | 61 | pass | byte-identical |
| pack-077 | multi (masses 58; 9 holes) | 58 | pass | byte-identical |

## Observations

- Pack loads whole: 200 accepted, 0 rejected.
- Fill, clear, complement, and drag-paint all behave on pack-075, and `DBG.2` agrees with the
  drawn marks. Unsolved marks do not complete a puzzle.
- pack-076 accepts a cross on every one of its 164 non-solution cells without solving, then
  solves on the last fill. pack-074 and pack-077 solve once and reach the result screen;
  ever-completed is set for both.
- Result screen resolves both the generated square and the pixel picture for pack-074 and
  pack-077. The pack-077 result draws its holed ring on a plinth, staring at N×N as the
  silhouette test expects (K4).

## Non-blocking marks

- `pack-077` is named single-subject on the issue (index 77 → 77 mod 10 = 7). The measured
  15×15 fill set is one 4-connected mass with 9 enclosed holes, so the class is
  "single-subject and holed" — permitted by the parent's "multi-subject and/or holed" side
  but not by its single-subject side as the epic words it. Measured cells have tiny gaps at
  some fill boundaries where the drawn square's dark tone rounds to just above the luma
  threshold (~2–4 cells move against a hand count). The pixel is byte-reproducible from its
  square under the fixed rule, fills are in band, the judge passes, and the picture reads
  clearly at 15×15, so this is recorded, not failed. Worth a wording check on #294.
- Screenshots 08 and 09 carry the same bytes: pack-077's last fill jumps straight to the
  result view, so the "board after the last fill" shot of this synthetic run shows the
  result state. It is the same frame as the result shot and is recorded as-is.
