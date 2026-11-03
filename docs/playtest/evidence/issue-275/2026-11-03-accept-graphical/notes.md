# Notes — issue #275 acceptance run

## Scope

The four rows `pack-170`–`pack-173` (all 15×15) and the eight picture entries they point at. Playtesting is required
because each row ships a different solution grid and clues and each gallery tile now resolves a picture pair.

Protocols judged: `PTU-play-puzzle`, `PTU-mark-input` (UX) and `PTD-ready-and-marks`, `PTD-crosses-and-fills`,
`PTD-solve-and-pb` (Design). `PTU-gallery-reset`, `PTD-pack-finished`, `PTU-leave-resume`, and `PTU-settings` are N/A:
a picture slice changes no reset, pack-completion, resume, or settings flow.

## What was judged

The probe drives the real shell, puzzle screen, and shipped input events over the shipped `data/pack.json` rows. Every
fill it places is one of the row's committed `solution-fills`, so a wrong clue, a wrong fill set, or a picture that
disagrees with its row would surface as a board that will not finish.

- pack-170: gallery → puzzle (`DBG.3`) → ready beat → stored one-fill-from-solve → last fill → result screen. Both
  `picture-id` and `pixel-picture-id` resolve on the result screen. Back shows exactly one completed tile, and #170's
  tile carries its own picture.
- pack-171: fill, clear, Fill-complement to cross, and a cross-drag over a clear run. `DBG.2` agreed with the drawn mark
  after every gesture. Leaving with unsolved marks keeps #170 as the only completed puzzle.
- pack-172: every non-solution cell crossed, then filled to solve, so the win lands with crosses present.
- pack-173: filled from its committed `solution-fills` to the result screen; `ever-completed` set.

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`; 35 `capture: PASS` lines; pack accepted 200, rejected 0.

## Blockers

None for playtesting.

**Outside this run's scope, not a bar miss:** the acceptance pass did not accept. No `deterministic` quality record
covers `game/` at this deliverable tree — the record under `docs/quality/evidence/issue-275/2026-11-03-verify/` names
`cf9b4d1`, and `game/` has moved 25 files since (sibling slices #467 and #469 rewrote rows and added pictures). Per
[`workflow-deterministic-record.md`](../../../../../docs/issues/workflow-deterministic-record.md) the issue returns to
`pending-verification` so the one legal producer can run. That belongs to verification; see the acceptance comment on
#275. No defect was filed.

## Look and structure (non-blocking observations)

- Warm pixels 0.00 % on all four pixels and all four squares; cool, neutral, calm — `AES.P1`.
- pack-170 and pack-173 are single connected masses, as their single-subject class requires. pack-171 is two masses;
  pack-172 is one mass declared multi-subject and/or holed. Neither enclosed region nor mass count is a bar miss: item 6
  binds the prompt, and the accepted #248 precedent shipped the same one-component multi-subject shape.
- pack-170 sits at the bottom edge of the 56–101 band (56 fills). `in_band` is true under the fixed luma rule and the
  puzzle is line-solvable with one solution, so it is a pass, not a near-miss to regenerate.
- Recorded for the epic #294, not this slice: the pack-wide distinctness and mix audit stays there as the task states.

## Build note

The graphical run was on `main@ef1c0b7`; the repo checks were on the same tree. Sibling slices landed after PR #453:
#467 (pack-174–177) and #469 (pack-178–179), each with its own catalog entries and `pack.json` rows. This slice's eight
picture pairs, eight catalog entries, and four rows are byte-identical between `d688934` (PR #453 merge) and `ef1c0b7`
(re-checked with `git diff`, [`logs/parity.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-275/2026-11-03-accept-graphical/logs/parity.log)).
