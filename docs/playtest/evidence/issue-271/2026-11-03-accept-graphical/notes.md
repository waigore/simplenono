# Notes — issue #271 acceptance

## What was judged, and how

The slice delivers eight static picture files (four generated squares, four 15×15 pixel files), their `.import`
sidecars, eight catalog entries, the regenerated manifest, and four rebuilt `pack.json` rows. No runtime code changed.
Two things can therefore go wrong for the player: a row whose fills or clues disagree with its picture, or a picture
pair that does not resolve on the gallery and result screens. The run judges exactly that, plus the slice's subject
classes against the shared picture bar on #294.

The capture is a graphical run (`xvfb-run`, not `--headless`) of `main@b3f8e82` through the real shell, puzzle
screen, and mark input, with real pointer events and the shipped `DBG.1`/`DBG.2`/`DBG.3` seams. Every fill it places
comes from the committed row's own `solution-fills`, so a wrong row shows up as a board that will not finish.

## Outcomes

- Gallery: 200 puzzles accepted, 0 rejected; none completed at the fresh shot.
- pack-155 (multi-subject, holed): opens from the gallery, Ready beat ends, one fill from solve completes it, the
  result screen draws **both** of its pictures, Back returns to a gallery where only #155 is Done.
- pack-156 (multi-subject): fill, clear, complement to cross, and drag-paint each match `DBG.2`; the unsolved marks do
  not complete the puzzle, and the gallery shows it In progress while #155 stays Done.
- pack-154 and pack-157: `solution-fills` equal the pixel's `Y < 128` cells, and each finishes on its last fill.
  pack-157 was crossed on all 149 non-solution cells first, so the win is proved to tolerate crosses
  (`PTD-crosses-and-fills` P1).
- `expectations_271.py` agrees with all four rows on fills and both clue axes, and agrees with the piece structure of
  each picture: 157 one mass + one cavity; 154 and 156 two masses, no cavity; 155 two masses, 27 enclosed cells.

## Screenshots not judged by the model

This session has no image input, so the nine screenshots were recorded and are on the wiki page but were not looked at
here. The judged state behind each one is asserted in `logs/capture.log` (35 `PASS` lines) and in the state dump
`logs/state-pack-157.json`. The "calm clinical look" read of the bar (`K4`) is carried by the `review` Pass already
recorded in each catalog entry, plus the measured proxies: 0.00 % warm pixels on all four pixel files and all four
squares, cool slate palette, high contrast (pixel luma p5/p95 spread of 110–155 levels per file).

## Row hygiene

`git diff 8c2a6db^ 8c2a6db -- game/data/pack.json` touches only pack-154…pack-157: four rows, four insertions and four
deletions, and the only semantic fields differing on every changed row are `solution-fills`, `row-clues`,
`col-clues`. `generate_pack.py --check` reports the committed file current at `b3f8e82`.

## Non-blocking observations (owned by #294, not this slice)

1. `pack-154`'s fill set is identical to `pack-046`, `pack-146`, and `pack-151` — four 15×15 puzzles ship the same
   picture and the same clues. `pack-155`, `pack-156`, and `pack-157` are unique in the pack. No bar item or spec row
   requires distinct pictures across puzzles, so this is not a Fail here; it belongs to the epic's pack-wide pass.
2. `pack-155`'s two masses are exactly the two pairs `puzzle_derive.py judge` lists as independent (row 5 and 6 each
   hold a `1` inside the cavity), so the judge correctly reports one solution. No action.

## Repo checks

`generate_pack.py --check`, `asset_manifest.py --check`, `asset_catalog.py`, `spec_lint.py` (0 errors, 1 pre-existing
glossary warning at `specs/view/glossary.md:12`) and 153 unit tests: all green. Logs on the wiki page.
