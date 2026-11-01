# Notes — issue #111 acceptance

**Verdict:** every acceptance criterion this deliverable can decide passes. Acceptance has
not advanced, because the required graphical evidence cannot exist on this build.

## What was judged

The deliverable is the presentation-layer mark path: `MarkInput` resolves pointer, touch,
and keyboard events over `PuzzleScreen` into exactly one `CTR-attempt.O2` per resolved
cell, using `MarkGesture`'s pure rules. It was judged headlessly at that seam: a probe
instantiated the real `PuzzleScreen` + `MarkInput` over a recording `Attempt` built from
the **shipped** `res://data/pack.json` (not the deliverable's own fixtures), and the
deliverable's own GUT suite was run unmodified.

## Layering

`grep` over `game/presentation/` finds no `apply_mark`, `auto_cross`, `allow_marks`,
`pause`, `restore_elapsed`, or `commit` call. The only attempt calls from presentation are
`attempt.mark` (O2, `mark_input.gd:184`), `attempt.open` (O1, `shell.gd:54`, from #112),
and `attempt.advance` (elapsed tick, `puzzle.gd:174`, from #110). No presentation file
preloads or loads anything outside `res://presentation/`.

## Why acceptance waits

Two independent gates block the graphical evidence, and neither is a fault in this
deliverable:

1. **No seam-complete build.** [`verification.md`](../../../../../specs/technical/verification.md)
   H1: seams precede playtesting, and "no gate run at `status:pending-acceptance` starts"
   on a build without S1–S4. `grep` over `game/` finds no `DBG.*` / `TEL.*` implementation,
   so no build in this repo is a valid playtest target yet.
2. **`IN` is protocol-orphaned for its own clauses.** `IN` is cited by `PTU-settings`
   alone ([`settings.md`](../../../../../specs/playtest/ux/settings.md)), whose steps are
   gallery → settings → Back and never place a mark; it also needs `UI-settings` (#95,
   Wave 2). No protocol runs US1.6–US1.8. The `IN` clauses were therefore judged at the
   GUT/`O2` seam, and no protocol clause can be recorded as failed.

Graphical reachability did change since the earlier holds: #112 (`f05441c`) routes the
shell to `puzzle.tscn` via its Open button, so marks are now playable by hand on
`main@881774e`. That does not satisfy either gate above: the build still has no S1–S4,
and the only protocol citing `IN` still needs the Wave-2 settings screen.

## Non-blocking observations

- `MarkInput._input` resolves a secondary click (`in_mark_complement`, B2) even while a
  primary stroke is open; the stroke then continues from its origin. No acceptance
  criterion covers the chord, so it is not judged here.
- `MarkInput._handle_mouse_button` does not check `event.pressed` for
  `in_mark_complement`; a release of button 2 is not `is_action_pressed`, so the current
  behaviour is correct, but it relies on Godot's action matching rather than an explicit
  guard.
- Both points are style-level; `review-code` passed the deliverable during verification
  and nothing here changes a judged outcome.

## Evidence hygiene

Native GUT logs contain ANSI escapes, repeated fixture warnings, and orphan-node dumps
from the test scenes. The stored logs are the same run with those three noise classes
removed; every test line, failure, assert count, and the exit status are preserved.
