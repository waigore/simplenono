# Criteria — issue #97 acceptance run

Epic body's acceptance-bearing scope, and where this run shows each one. "Cited" means the evidence lives in
another accepted issue's run and this deliverable does not change it.

| Epic scope item | What was judged | Evidence | Outcome |
|-----------------|-----------------|----------|---------|
| `END` `W1` — win on fill-set match | The 200th first-solve on `pack-199` and three replays on `pack-000` each end in a win from a mark | `logs/capture-console.log` (`P1: the last puzzle is ever-completed`, `04/05/06: ever-completed is true`), screenshots `02`, `04`–`06` | pass |
| `END` `W1` — timer stops, marks/elapsed clear, attempt not started | Record after each solve: `in_progress false`, `elapsed 0`, `marks null`, attempt `not_started` | `logs/state-s3-pack-finished.json`, `logs/state-final.json` | pass |
| `END` `W1` — personal best kept when equal or shorter | 60 → 59 (shorter, replaced), 59 → `10:00` (longer, kept), 59 → `0:08` (shorter, replaced) | `logs/state-04-*.json`, `logs/state-05-*.json`, `logs/state-06-*.json`; `P2`/`P3` check lines | pass |
| `END` `W2` — pack finished at rate 1 | 199/200 reads not finished at 0.995; the 200th first-solve reads exactly 1 and finished | `P2: GS.completion-rate is 1`, `P2: CMP-pack serves pack finished`; screenshots `00`, `03` | pass |
| `END` `P1` — W2 after W1, not instead of it | The closing solve sets its own puzzle's W1 facts *and* the pack fact in the same transition | `logs/state-s3-pack-finished.json` (ever-completed true, PB 137, elapsed 0) beside `P2 rate=1.0 finished=true` | pass |
| `END` `P1` — W1/O1 exclusive | Not re-driven here: the win opened the result screen (`NAV.T4`) and no gallery return fired, which is consistent with but does not prove exclusivity. The assertion lives in `test_solve_edge.gd` (verify comment) and #109's run | `#109` run; verify comment | cited |
| `END` `O1` — leave | Cited: unchanged by this deliverable | `#95` runs | cited |
| `END` `O2` — gallery reset as new | Cited: unchanged by this deliverable; the run itself uses O7 to build its fixture without changing behaviour | `#94` runs; probe `reset_puzzle` calls in the capture log | cited |
| `PRG` `Z1` — pack finished | Same fact as `END.W2`; observed through `CMP-pack` O2 | `P2 rate=1.0 finished=true` | pass |
| `PRG` `Z2` — replay after finish / after ever-completed | Three replays after 200/200 all solve normally and the pack stays finished at rate 1 | `04/05/06: the pack stays finished through the replay`, `completion rate stays 1` | pass |
| `PS1.1`–`PS1.7` (endings scenarios) | Covered by the rows above, `#109`'s S1 for `PS1.1`'s "PB none" start, and `#95` for the result reveal | `notes.md` non-blocking observations | pass / cited |
| Playtest protocol `PTD-pack-finished` (S1–S3, P1–P2, F1) | Run end to end on the shipped 200-puzzle pack | `manifest.md` result table; screenshots `00`–`03` | pass |
| Playtest protocol `PTD-solve-and-pb` (S1–S3, P1–P3) | Run end to end after the pack closed; S1 starts from PB 60 (see notes) | `manifest.md`; screenshots `04`–`06` | pass |
| Deterministic quality record covering this `game/` tree | Six Applies axes re-observed at `b9c5668` | `docs/quality/evidence/issue-97/2026-11-02-accept-deterministic/manifest.md` | pass |

The epic's original body named `PTD-crosses-and-fills`; that protocol cites `E-clue`/`GS` and is #95's
subject. The verify comment corrected the protocol set to the two above, which is what was run.
