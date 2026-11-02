# Notes — issue #249 acceptance

Judged at `main@212c7e0` (the PR #369 squash `6cf2cbc` is an ancestor; none of this slice's
files changed since). Scope: the protocols pack-066…pack-069 can reach. Nothing else moved.

## What was judged

- **`PTU-play-puzzle`** — the shell loads all 200 puzzles with no rejected entry, pack-066
  opens from the gallery, the Ready beat gates marks, the last fill emits `solved` once,
  the result screen resolves *both* ids (generated square and pixel) for pack-066 and
  pack-069, and Back returns to a gallery showing the completed tile.
- **`PTU-mark-input`** — on pack-067, real input events fill, clear, complement, and
  drag-paint; `DBG.2` agrees with the drawn marks on the fill and the cross; unsolved marks
  do not mark the puzzle complete.
- **`PTD-ready-and-marks`** — marks are refused before the Ready beat and allowed after it.
- **`PTD-crosses-and-fills`** — on pack-068 all 163 non-solution cells are crossed, then the
  fill set wins the board.
- **`PTD-solve-and-pb`** — the win lands once and `ever_completed` is set for pack-068 and
  pack-069.

The board will not finish unless the committed `solution-fills` and clues are exactly the
pixel's dark cells, so a wrong clue or a mismatched pixel shows up as a dead board rather
than a silent pass.

## Non-blocking marks

- **pack-067 is recorded as single-subject but measures 4 enclosed holes.** Under the #294
  bar the class is an index-rule assignment (67 mod 10 = 7 → single) and the pack-wide ~30/70
  mix check (`V2`, `K5`) belongs to #294, not this slice. The silhouette still reads at 15×15
  and passes `S4`/`K3` with one line-logic solution. Reported here, not a defect.
- `spec_lint.py` shows 1 warning: `specs/view/glossary.md:12 'Diagram'` is also defined in
  `specs/technical/glossary.md`. Pre-existing, unrelated to this slice.

## Blockers

None.
