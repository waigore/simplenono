# Notes — issue #276 acceptance run

## Scope

The four rows `pack-174`–`pack-177` (all 15×15) and the eight picture entries they point at. Playtesting is required
because each row ships a different solution grid and clues and each gallery tile now resolves a picture pair.

Protocols judged: `PTU-play-puzzle`, `PTU-mark-input` (UX) and `PTD-ready-and-marks`, `PTD-crosses-and-fills`,
`PTD-solve-and-pb` (Design). `PTU-gallery-reset`, `PTD-pack-finished`, `PTU-leave-resume`, and `PTU-settings` are N/A:
a picture slice changes no reset, pack-completion, resume, or settings flow.

## What was judged

The probe drives the real shell, puzzle screen, and shipped input events over the shipped `data/pack.json` rows. Every
fill it places is one of the row's committed `solution-fills`, so a wrong clue, a wrong fill set, or a picture that
disagrees with its row would surface as a board that will not finish.

- pack-174: gallery → puzzle (`DBG.3`) → ready beat → stored one-fill-from-solve → last fill → result screen. Both
  `picture-id` and `pixel-picture-id` resolve on the result screen. Back shows exactly one completed tile, and #174's
  tile carries its own picture.
- pack-175: fill, clear, Fill-complement to cross, and a cross-drag over a clear run. `DBG.2` agreed with the drawn mark
  after every gesture. Leaving with unsolved marks keeps #174 as the only completed puzzle.
- pack-176: every non-solution cell crossed, then filled to solve, so the win lands with crosses present.
- pack-177: filled from its committed `solution-fills` to the result screen; `ever-completed` set.

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`; 35 `capture: PASS` lines; pack accepted 200, rejected 0.

## Blockers

None for playtesting.

**Outside this run's scope, not a bar miss:** the acceptance pass returned the issue to `pending-verification` for a
missing `deterministic` quality record covering `game/` at the deliverable tree. That belongs to verification; see the
acceptance comment on #276.

## Look and structure (non-blocking observations)

- Warm pixels 0.00 % on all four pixels and all four squares; cool, neutral, calm — `AES.P1`.
- pack-177 is a single solid mass, as its single-subject class requires. pack-174, pack-175, and pack-176 are two
  masses each, which satisfies "multi-subject and/or holed". None of the four has an enclosed region; the class allows
  either form, so that is not a miss.
- Recorded for the epic #294, not this slice: the pack-wide distinctness and mix audit stays there as the task states.

## Build note

The graphical run was on `main@a8b3848`; the repo checks were on the same tree. Sibling slices landed after PR #467:
#470 (evidence only, no `game/` change) and #469 (pack-178–179, its own four catalog entries and `pack.json` rows).
This slice's eight picture pairs, eight catalog entries, and four rows are byte-identical between `5b260e8` (PR #467
head) and `a8b3848` (re-checked with `git diff`).
