# Notes — issue #108 acceptance

## What was judged

The `GS` story row at the shipped domain seam: `Rules` (`CMP-rules`, `CTR-rules` O1–O2) and
`AttemptState` / `ProgressRules` / `ProgressRecord` (`CMP-attempt`, `CMP-pack`). One probe test per
story row, each with negative cases ([`probe-accept-108-gs.gd`](probe-accept-108-gs.gd),
[`logs/probe-gs.log`](logs/probe-gs.log), 5 tests, 49 asserts).

| Story | Observed at the seam |
|-------|----------------------|
| PS1.1 / V5 | Solution fills with crosses elsewhere → solved; one extra fill or one missing fill → not; cells stay clear/fill/cross |
| PS1.3 / PS1.3b | One fill inside row 4 (`[5]`) and column 6 (`[8]`) → no error; a fill on empty column 0 → error |
| PS1.4 / PS1.4b | Row 4 filled at columns 5–9 (`[5]`) → satisfied; one extra fill → not |
| PS1.6 / V2 | Blocked mark rejected; first fill → in progress; paused mark rejected and unwritten; clear/solve → not started, elapsed 0; empty-clue auto-cross alone → in progress |
| PS1.2 | Empty pack 0.0; no solves 0.0; 3/10 = 0.3; 3/4 = 0.75; 3/200 = 0.015 |
| PS1.5 / V1 / V4 | Flag off → on at PB 30 → off after reset; longer solve keeps PB, shorter replaces it |
| PS1.7 / Q1 | Identical marks, solve, and status across two replays |
| G3 / H2 | Grid snapshot unchanged by three rule calls; `solution_fills()` is a copy |
| V6 | Replay commits in progress while `ever_completed` and PB survive |

Falsification: forcing `is_solved` to `return true` fails the extra-fill assertion
([`logs/probe-mutation-solve.log`](logs/probe-mutation-solve.log), exit 1). Source was restored
before the suite log.

## Blockers

- **No `DBG.*` / `TEL.*` seam.** [`verification.md`](../../../../../specs/technical/verification.md)
  H1 bars a gate run without S1–S4; `grep` over `game/` finds neither
  ([`logs/criteria-greps.log`](logs/criteria-greps.log)). `PTD-ready-and-marks` S1 needs `DBG.3`
  and the evidence rule needs `DBG.2`, so the protocol cannot run as written.
- **Partial display only.** Line error and clue satisfied reach the board's clue styling, but no
  screen shows attempt status, completion rate, or the thumbnail flag (gallery is later work), and
  S1/S2 have no seam to drive or inspect the `GS` values.

Both are missing seams owned by later work, the same hold recorded for #105 / #106 / #107 / #109 /
#111 / #112 / #156 ([`../../accept-dispatch-deadlock.md`](../../accept-dispatch-deadlock.md)).
Per the accept skill's **waiting on screenshots** outcome the issue stays
`status:pending-acceptance`; no defect and no status gate.

## Non-blocking marks

- `PTD-ready-and-marks` P2 is judgeable: the teapot has empty rows 0–3 and empty columns 0–1 and
  13–14, and the auto-cross ran and started the attempt.
- No Applies deterministic axis can move: progress stays in memory (`progress_rules.gd` header),
  with no persistence, frame, or load path. No `deterministic` record is owed.
- No `llm-judge` axis applies (`rubrics.md` has no domain axes).
- Test count moved from 120 at verification to 125 on `main@67e36f5` because #156's regression
  tests landed; `test_game_state.gd` is still in the run (10 scripts).
