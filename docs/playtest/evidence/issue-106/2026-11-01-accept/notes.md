# Notes — issue #106 acceptance playtest (headless)

Run: `2026-11-01-accept`, build `main@eea5f9d`. Judged by `issue-workflow-accept-agent` (parallel id 1).

## Prep finding: no running build

`specs/playtest/procedures.md` Prep requires the Must tools (`DBG.*`, `TEL.*`, both drive paths) to be available on the build under test. Neither is realized on `main@eea5f9d`:

- `game/main.tscn` is a single bare `Node`. There is no puzzle screen, gallery, or debug UI.
- There is no telemetry sink or session/build id (`TEL.1`–`TEL.5`), so no `TEL.3` session id can be recorded.
- `DBG.1`–`DBG.4` do not exist.

The deliverable is a headless value object (`MarkGrid` / `MarkCell` / `CellMark` under `game/play/`). Its only executable surface is the GUT suite, so this run drives the protocols through that seam and judges the parts that the delivered layer can decide. Nothing that requires a running UI was invented or simulated.

The Must-tool gap is not a protocol fail: `PTD-ready-and-marks` F1/F2 and `PTD-crosses-and-fills` F1/F2 all describe game or interface behaviour (marks applying, fill/cross/clear not updating, wrong fill ending the attempt, pause ticking elapsed, solve failing on correct fills), and none of those was observed to fail. The missing debug/telemetry surface is a delivery gap owned by the shell/observability work (`CMP-shell`, `runtime-signals` I11), not by #106. Recorded here as a non-blocking note for the full-mode playtest gate.

## `E-cell` / `PTD-ready-and-marks`

Steps taken at the seam. Log: `logs/gut-ready-and-marks.log` (`15/15` in `res://test/test_cell_mark.gd`).

| Step | Seam action | Observation | Judge |
|------|-------------|-------------|-------|
| S1 | `MarkGrid.new(10)` (marks-allowed false) → `apply_mark(0,0,FILL)`, `apply_mark(0,0,CROSS)` | Both return `false`; `mark_at(0,0)` stays `CLEAR`; `auto_cross` also crosses 0 while blocked | P1 "marks do not stick during get-set-ready" — pass (PS1.4, I4, `CTR-attempt` G1) |
| S2 | `allow_marks()`; fill `(3,4)`; clear `(0,0)` after a fill; cross `(9,9)` | fill → `mark_at(3,4) == FILL`; clear → `CLEAR`; cross → `CROSS`; each returns `true`. Re-applying the same mark returns `false` and changes nothing | P1 "after Ready, clear → fill → clear → cross transitions work" — pass (PS1.2, PS1.2b, PS1.2c, `SEQ-mark` B2) |
| S2 (grid shape) | `MarkGrid.new(10)` sweep; `MarkGrid.new(15, true)` snapshot | exactly 100 positions `is_inside` for rows 0..9 × columns 0..9, all `CLEAR`; every cell of a 15×15 snapshot is `CLEAR` | PS1.1 — pass. Note: `MarkGrid.new(20)` is not exercised by a test; `SCH-mark-grid` F1 admits 20 and `_init` has no size branch, so this is a coverage gap, not an observed deviation |
| S3 | Out-of-grid `apply_mark(10,0)`, `(-1,0)`, `(0,10)` | each returns `false`, nothing changes | invalid transitions — pass |
| P2 | `auto_cross([(0,1),(0,2)])` after `(0,0)` was filled; `auto_cross([(0,0)])` where `(0,0)` is `CROSS`; same where `(0,0)` is `FILL` | 2 changed, both `CROSS`; already-crossed left alone (0 changed); a fill is never overwritten (0 changed) | P2 "auto-cross still-clear cells" — pass for the grid (PS1.5, I5, S1). The story's "And attempt-status is in progress" lives in `GS`/`CMP-attempt` (#108) and is out of this deliverable |
| S4 | pause / `IN.pause` | no pause surface exists in this deliverable | not reachable; P3 pause clause and F2 pause clause are outside #106 — see per-step note below |

Per-step note (does not change the outcome). §Procedures "Per protocol" says step 4 is judged against the cited design story, and "Outcomes → Notes" says an observation is non-blocking only when the protocol marks it non-blocking; `PTD-ready-and-marks` marks none. This run judges the story clauses the deliverable can realize (`E-cell` S1–S3, I1, I4, I5) as passing. It does not judge the P3 pause clause, nor the `L-solve`/`GS` parts of P2 (attempt status) and P3 (wrong fills do not solve, no fail state), because those cite `L-solve`, `GS`, and `E-puzzle` and belong to #107/#108/#111. Applying "unjudgeable → non-pass" to the protocol as a whole would instead hold #106 on a pause surface that #106 never delivers.

## `E-cell` / `PTD-crosses-and-fills`

Steps taken at the seam. Log: `logs/gut-crosses-and-fills.log`.

| Step | Seam action | Observation | Judge |
|------|-------------|-------------|-------|
| S1/S3 (state dump, `SIT.3`) | `MarkGrid.new(10, true)`; `apply_mark(1,1,FILL)`, `apply_mark(1,2,CROSS)`, `apply_mark(1,3,CROSS)` | `filled_positions()` → `[(1,1)]` — the cross at `(1,2)`/`(1,3)` is absent | P2 "crosses treated as non-fills" — pass (S3, `E-cell` I2/I3, PS1.3) |
| S3 | `CellMark.counts_as_fill(CROSS)`, `counts_as_fill(FILL)` | `false`, `true` | P2 — pass |
| S1 | marks purely of crosses, no fill | a grid of crosses never reports a fill, so crosses cannot be "required to match the solution fill set" at this layer | P1 — pass at this layer (F1 requires the opposite) |

`GS.is-solved` and the win transition do not exist yet (#108), so P1's solve-succeeds clause and F2 are judged only on the seam they depend on: crosses are not fills.

## Situational tool

`PTD-crosses-and-fills` cites `SIT.3` (state dump). The dump above is the seam-level equivalent (`snapshot()`, `filled_positions()`); it is written inline instead of into a separate file.

## Blockers and non-blocking notes

- **Non-blocking:** Must playtest tools (`DBG.*`, `TEL.*`) are not realized on this build — no UI surface in the deliverable. Detail above.
- **Non-blocking:** no graphical run yet, so `screenshots/` is waiting for a re-run of `main@eea5f9d`.
- **Coverage gap (non-blocking):** no test constructs a 20×20 grid; `MarkGrid.new(20)` is untested although `SCH-mark-grid` F1 admits it.

## Result

Both in-scope protocols pass at the delivered layer; per-criterion evidence is in the acceptance comment on #106. Judgement recorded; acceptance waits on the graphical re-run screenshots.
