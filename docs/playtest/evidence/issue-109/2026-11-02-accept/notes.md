# Notes — #109 accept

## What was judged and how

`L-solve` is owned by #109, so the set is `L-solve` and every protocol citing it: `PTD-solve-and-pb` and the `L-solve` clauses of `PTD-ready-and-marks`.

**Prep gap.** `PTD-solve-and-pb` S1 needs `DBG.3` ("into a not-started puzzle one correct fill from solve") and its evidence rule needs `DBG.2` to read the PB. Neither exists, and neither does a board: the `draw_`/`DBG.`/`TEL.` grep over `game/` (minus `addons/`) is empty, and the only first-party scene is the `game/presentation/shell.tscn` text stub.

This is a prep gap, not a deliverable fault: the issue delivers the solve *edge* in `game/play/`, not a screen. The protocol was judged at the seam it describes — open, end the beat, advance the clock, place the fill — reading the same observation points S1–S3 ask for (attempt status, marks, elapsed, PB, ever-completed) from the persisted record and the attempt instead of `DBG.2`. The probe imports none of `test_solve_edge.gd`'s doubles.

## Judgement

- **PS1.4 / crosses-and-fills seam — pass.** Wrong fill stays, `is-solved` false, no E1, no solve recorded, attempt in progress, clock running.
- **PS1.5 / P1 — pass.** From PB none, the solving fill at elapsed 50 leaves `ever_completed: true`, `personal_best: 50`, `in_progress: false`, no stored marks, elapsed 0, attempt not started and empty. E1 fires once as `["teapot", 50]`.
- **PS1.6 / P2 — pass.** PB 50, replay solved at 100: PB stays 50, ever-completed true, not started.
- **P3 — pass.** PB 50, replay at 15: PB becomes 15, marks and elapsed clear again.
- **G1 — pass.** Paused fill: grid and returned grid unchanged, no E1, no solve, stored elapsed untouched, clock frozen.
- **B3 — pass, structurally.** A solve leaves the *solved* record shape (O6 only); a non-solving mark leaves the *in-progress* shape with running elapsed (O5 only). No spy on either call.

## A finding that was mine, not the build's

The first probe run failed P2: a longer replay (100) replaced PB 50. The cause was the probe's seed — it cleared the record with `ProgressRules.reset()`, which is O7, the **gallery** reset: it clears ever-completed but deliberately keeps `personal_best`. So the "first solve" started from PB 50 instead of none. With the `reset` removed, all five tests pass, and mutation 1 shows P2 still follows the shipped rule.

## Why acceptance still waits

[`evidence.md`](../../../../../specs/playtest/evidence.md) requires ≥1 screenshot of each judged state from a graphical re-run of the same build. Nothing draws and there is no `DBG.*`/`TEL.*`, so the screenshot is gated on #110, #111, and the shell surface — not on #109. No defect: the game is not wrong at this layer.

## Flags for the planner (not filed)

- **The deadlock now covers #109** — a fourth leaf, same disposition, same options in [`accept-dispatch-deadlock.md`](../../accept-dispatch-deadlock.md).
- **`PTD-solve-and-pb` needs `DBG.3`/`DBG.2` no build has.** Once the shell surface lands it is the cleanest first graphical acceptance here.
- **GUT still exits 0 on an unparseable test script.** Unchanged and unowned; #127 covers lint, not this.
