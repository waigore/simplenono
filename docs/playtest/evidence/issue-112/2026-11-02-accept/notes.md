# Notes — issue #112 acceptance

**Verdict:** every acceptance criterion this deliverable can decide passes. Acceptance has not
advanced: the required graphical evidence cannot exist on this build, and no `deterministic`
quality record exists for the commit.

## What was judged

The deliverable is the shell → puzzle open leg: `Shell` loads the shipped pack once
(`CTR-pack` O8), holds one `Attempt`, and `open_puzzle(id)` runs `SEQ-open` S1–S6 through
`CTR-attempt` O1 before swapping to `PuzzleScreen`. It was judged headlessly with a probe that
instantiates the real `shell.tscn` and loads the **shipped** `res://data/pack.json`, so the
deliverable's own fixtures were not reused.

- All 200 shipped ids open, in reverse pack order, so the proof cannot lean on pack order or
  solve-order gating. Each open creates a fresh attempt, shows the puzzle screen, hides `Home`,
  presents the same attempt to the screen, runs S2, keeps marks blocked (S4), returns the grid
  with elapsed 0 (S5), and refuses every id that is not in the pack.
- `E3` `ready` fires once when the screen's beat ends, carrying the open id, the live grid, and
  line status; marks unblock afterwards (S12–S13).
- The unknown-id branch changes nothing: same attempt, id, marks, elapsed, and beat.
- C1 leave clears the attempt and returns to the shell view; another id opens.
- The shell holds no gallery, result, settings, or progress surface, and `shell.gd` has no
  `user://` / `ConfigFile` path.

Layering: `grep` over `game/presentation/` finds only `attempt.open` (O1, shell),
`attempt.mark` (O2, #111), and `attempt.advance` (elapsed, #110). The shell sends O1 and O6 and
never writes a mark, record, or derived value.

## Why acceptance waits

Two independent gates, neither a fault in this deliverable:

1. **No graphical evidence.** [`verification.md`](../../../../../specs/technical/verification.md)
   H1 bars a gate run on a build without S1–S4, and `grep` finds no `DBG.*` / `TEL.*` in
   `game/`. Separately, the only protocol citing this journey, `PTU-play-puzzle`, needs
   `UI-gallery`, `UI-result`, and `END.W1` (#94, #95), so its default evidence rule needs
   screenshots this build cannot produce.
2. **No deterministic quality record.** Two Applies axes can move here: `response-delay` ("open
   puzzle … acknowledges ≤ 500 ms") and `transition-latency` (the shell → puzzle swap).
   [`docs/quality/evidence/`](../../../../quality/evidence/README.md) holds records for #99 and
   #101 only — none for #112 at `f05441c` (still the code under acceptance) or `b290095`. The
   #112 verification comment deferred transition latency to this run, but
   [`run-quality-evaluators`](../../../../../.agents/skills/run-quality-evaluators/SKILL.md)
   allows `deterministic` mode only from verify or a user request; acceptance must not run it.

Per the accept skill's "Waiting" outcomes, the issue stays `status:pending-acceptance` with no
defect and no gate.

## Non-blocking observations

- `Shell.open_puzzle` calls `Pack.definition` for the B1 guard and `Attempt.open` calls it again
  for S2 — one redundant lookup, not a contract violation.
- The verification comment says both "no Applies deterministic axis can move" and "transition
  latency belongs to the #112 acceptance run". This run records the second reading; settling it is
  a workflow question, not a code defect.
- The suite reports 120 tests, not the 145 quoted at `881774e`: #158 rewrote
  `game/test/test_game_state.gd` (+331/−488). All 10 scripts still pass.
