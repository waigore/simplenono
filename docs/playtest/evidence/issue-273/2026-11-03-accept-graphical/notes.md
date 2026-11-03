# Notes — issue #273 acceptance run

## Scope

The four rows `pack-162`–`pack-165` (all 15×15) and the eight picture entries they point at. Playtesting is required
because each row ships a different solution grid and clues and each gallery tile now resolves a picture pair.

Protocols judged: `PTU-play-puzzle`, `PTU-mark-input` (UX) and `PTD-ready-and-marks`, `PTD-crosses-and-fills`,
`PTD-solve-and-pb` (Design). `PTU-gallery-reset`, `PTD-pack-finished`, `PTU-leave-resume`, and `PTU-settings` are N/A:
a picture slice changes no reset, pack-completion, resume, or settings flow.

## What was judged

The probe drives the real shell, puzzle screen, and shipped input events over the shipped `data/pack.json` rows. Every
fill it places is one of the row's committed `solution-fills`, so a wrong clue, a wrong fill set, or a picture that
disagrees with its row would surface as a board that will not finish.

- pack-162: gallery → puzzle (`DBG.3`) → ready beat → stored one-fill-from-solve → last fill → result screen. Both
  `picture-id` and `pixel-picture-id` resolve on the result screen. Back shows exactly one completed tile, and #162's
  tile carries its own picture.
- pack-163: fill, clear, Fill-complement to cross, and a cross-drag over a clear run. `DBG.2` agreed with the drawn mark
  after every gesture. Leaving with unsolved marks keeps #162 as the only completed puzzle.
- pack-164: every non-solution cell crossed, then filled to solve, so the win lands with crosses present.
- pack-165: filled from its committed `solution-fills` to the result screen; `ever-completed` set.

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`; 35 `capture: PASS` lines; pack accepted 200, rejected 0.

## Blockers

None.

## Look and structure (non-blocking observations)

- Warm pixels 0.00 % on all four pixels and all four squares; cool, neutral, calm — `AES.P1`.
- Classes match the body: pack-163 is a single solid stepped mass (single-subject); pack-162 is one mass with one
  enclosed 4-cell hole, and pack-164 / pack-165 are two separated masses each — all three satisfy "multi-subject and/or
  holed".
- Recorded for the epic #294, not this slice: the pack-wide distinctness and mix audit stays there as the task states.

## Build note

The graphical run was on `main@e945c88`. The slice landed at `df95619` (PR #445); this slice's eight picture pairs,
eight catalog entries and four rows are byte-identical between the two trees.
