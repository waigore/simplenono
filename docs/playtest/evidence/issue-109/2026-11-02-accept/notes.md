# Notes — #109 accept

## What was judged and how

`L-solve` is owned by #109, so the required set is `L-solve` and every protocol citing it:
`PTD-solve-and-pb` and the `L-solve` clauses of `PTD-ready-and-marks`.

**Prep gap.** `PTD-solve-and-pb` cites `DBG.3` in S1 ("`DBG.3` into a not-started puzzle one
correct fill from solve") and `DBG.2` in its evidence rule ("Record PB values from `DBG.2`
in notes"). Neither surface exists on this build, and neither does a board:

- `grep -rn -e 'draw_' -e 'DBG\.' -e 'TEL\.' game --include='*.gd' --include='*.tscn'`
  (excluding `addons/`) returns nothing.
- The only first-party scene is `game/presentation/shell.tscn`, a text stub.

That is the same prep gap every Wave-1 leaf has hit, and it is not a fault of this
deliverable: the issue delivers the solve *edge* in `game/play/`, not a screen. So the
protocol was judged at the seam it actually describes — open, end the beat, advance the
clock, place the fill — with the same observation points S1–S3 ask for (attempt status,
marks, elapsed, PB, ever-completed), read from the persisted record and the attempt instead
of from `DBG.2`. The probe is independent of `test_solve_edge.gd`: it imports none of that
file's doubles and builds its own pack, seed, and reader.

## Judgement

- **PS1.4 / `PTD-crosses-and-fills` P1 seam — pass.** With one fill differing from the
  solution, the fill stays, `is-solved` is false, no E1 is emitted, no solve is recorded,
  and the attempt stays in progress with the clock still running.
- **PS1.5 / `PTD-solve-and-pb` P1 — pass.** PB none; the solving fill at elapsed 50 leaves
  `ever_completed: true`, `personal_best: 50`, `in_progress: false`, no stored marks, stored
  elapsed 0, attempt not started, its marks empty and elapsed 0. E1 fires once with
  `["teapot", 50]`.
- **PS1.6 / P2 — pass.** PB 50, replay solved at 100: PB stays 50, ever-completed stays
  true, attempt not started.
- **P3 — pass.** PB 50, replay solved at 15: PB becomes 15, marks and elapsed clear again.
- **G1 — pass.** Paused fill: grid unchanged, the returned grid unchanged, no E1, no solve
  recorded, stored elapsed untouched, and the clock stays frozen at 50.
- **B3 (O5 vs O6) — pass, observed structurally.** On a solve the record comes back in the
  *solved* shape, which only O6 produces; on a non-solving mark it comes back in the
  *in-progress* shape with the running elapsed, which only an O5 commit with
  `in_progress = true` produces. The probe does not spy on either call.

## A finding that was mine, not the build's

The first probe run failed P2: a longer replay (100) replaced PB 50 with 100. The cause was
in the probe's own setup, not the build. It seeded the "first solve" by calling
`ProgressRules.reset()`, and `reset` is O7, the **gallery** reset: it clears ever-completed
but deliberately leaves `personal_best` (a gallery reset makes a puzzle new, it does not
erase the player's record). The seed then carried PB 50 into a scenario that is supposed to
start from PB none. Removed the `reset` from the seed; all five tests then passed, and
mutation 1 shows the P2 branch still decides the rule correctly. See `falsification.md`.

## Why acceptance still waits

`specs/playtest/evidence.md` requires ≥1 screenshot of each judged state from a graphical
re-run of the same build. Nothing draws: there is no board, no clue bar, no `DBG.*`, and no
`TEL.*` on this build, so `PTD-solve-and-pb`'s judged state cannot be photographed. The
screenshots are gated on the puzzle screen (#110), mark input (#111), and the shell's
debug/telemetry surface, not on anything #109 can add. No defect: the game is not wrong at
the layer this task delivers.

## Flags for the planner (not filed)

- **The deadlock now covers #109 too.** `docs/playtest/evidence/accept-dispatch-deadlock.md`
  covers #105/#106/#107; #109 is the fourth leaf with the same disposition and the same
  unblocking options, each a spec or workflow change this agent must not make.
- **`PTD-solve-and-pb` requires `DBG.3`/`DBG.2` that no build has.** The protocol is
  correctly written; the build cannot enter a near-solve state or read a PB. Once the shell
  surface lands, this protocol becomes fully runnable — it is the cleanest candidate for
  the first graphical acceptance in this project.
- **GUT still exits 0 when a test script fails to parse.** Not re-hit this run (all 8
  scripts were counted), but still unowned; #127 covers lint, not this.
