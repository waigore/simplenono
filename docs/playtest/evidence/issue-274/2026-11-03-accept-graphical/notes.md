# Notes — issue #274 acceptance run

## Scope

The four rows `pack-166`–`pack-169` (all 15×15) and the eight picture entries they point at. Playtesting is required
because each row ships a different solution grid and clues and each gallery tile now resolves a picture pair.

Protocols judged: `PTU-play-puzzle`, `PTU-mark-input` (UX) and `PTD-ready-and-marks`, `PTD-crosses-and-fills`,
`PTD-solve-and-pb` (Design). `PTU-gallery-reset`, `PTD-pack-finished`, `PTU-leave-resume`, and `PTU-settings` are N/A:
a picture slice changes no reset, pack-completion, resume, or settings flow.

## What was judged

The probe drives the real shell, puzzle screen, and shipped input events over the shipped `data/pack.json` rows. Every
fill it places is one of the row's committed `solution-fills`, so a wrong clue, a wrong fill set, or a picture that
disagrees with its row would surface as a board that will not finish.

- pack-166: gallery → puzzle (`DBG.3`) → ready beat → stored one-fill-from-solve → last fill → result screen. Both
  `picture-id` and `pixel-picture-id` resolve on the result screen. Back shows exactly one completed tile, and #166's
  tile carries its own picture.
- pack-167: fill, clear, Fill-complement to cross, and a cross-drag over a clear run. `DBG.2` agreed with the drawn mark
  after every gesture. Leaving with unsolved marks keeps #166 as the only completed puzzle.
- pack-168: every non-solution cell crossed, then filled to solve, so the win lands with crosses present.
- pack-169: filled from its committed `solution-fills` to the result screen; `ever-completed` set.

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`; 35 `capture: PASS` lines; pack accepted 200, rejected 0.

## Blockers

None.

## Look and structure (non-blocking observations)

- Warm pixels 0.00 % on all four pixels and all four squares; cool, neutral, calm — `AES.P1`.
- pack-167 is a single solid mass, as its single-subject class requires. pack-166, pack-168, and pack-169 are two
  masses each, which satisfies "multi-subject and/or holed". None of the four has an enclosed region; the class allows
  either form, so that is not a miss.
- The earlier implementation attempt on this task stopped on a missing `CHEAPERINFERENCE_API_KEY` (comment on #274);
  the later run generation proceeded under the documented fallback variable. Not a bar item and not a blocker for
  acceptance, which judges the committed pictures.
- Recorded for the epic #294, not this slice: the pack-wide distinctness and mix audit stays there as the task states.

## Build note

The graphical run was on `main@ec135ed`; the repo checks were on the same tree. A sibling slice (#469, pack-178–179)
merged as `0eb2d1d` during the run. It changed four of its own catalog entries and its own `pack.json` rows; this slice's
eight picture pairs, eight catalog entries, and four rows are byte-identical between `ac52f1a` (PR #448 head) and
`0eb2d1d` (re-checked with `git diff`).
