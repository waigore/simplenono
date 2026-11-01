# Prep and seam method — issue #106 acceptance playtest (headless)

Run: `2026-11-01-accept`, build `main@eea5f9d`. Judged by `issue-workflow-accept-agent` (parallel id 1).

## Prep finding: no running build

`specs/playtest/procedures.md` Prep requires the Must tools (`DBG.*`, `TEL.*`, both drive paths) to be available on the build under test. Neither is realized on `main@eea5f9d`:

- `game/main.tscn` is a single bare `Node`. There is no puzzle screen, gallery, or debug UI.
- There is no telemetry sink or session/build id (`TEL.1`–`TEL.5`), so no `TEL.3` session id can be recorded.
- `DBG.1`–`DBG.4` do not exist.

The deliverable is a headless value object (`MarkGrid` / `MarkCell` / `CellMark` under `game/play/`). Its only executable surface is the GUT suite, so this run drives the protocols through that seam and judges the parts that the delivered layer can decide. Nothing that requires a running UI was invented or simulated.

The Must-tool gap is not a protocol fail: `PTD-ready-and-marks` F1/F2 and `PTD-crosses-and-fills` F1/F2 all describe game or interface behaviour (marks applying, fill/cross/clear not updating, wrong fill ending the attempt, pause ticking elapsed, solve failing on correct fills), and none of those was observed to fail. The missing debug/telemetry surface is a delivery gap owned by the shell/observability work (`CMP-shell`, `runtime-signals` I11), not by #106. Recorded here as a non-blocking note for the full-mode playtest gate.

## Boundary of judgement

§Procedures "Per protocol" says step 4 is judged against the cited design story, and "Outcomes → Notes" says an observation is non-blocking only when the protocol marks it non-blocking; `PTD-ready-and-marks` marks none. This run judges the story clauses the deliverable can realize (`E-cell` PS1.1–PS1.5, S1–S3, I1–I5) as passing. It does not judge the P3 pause clause, nor the `L-solve`/`GS` parts of P2 (attempt status) and P3 (wrong fills do not solve, no fail state), because those cite `L-solve`, `GS`, and `E-puzzle` and belong to #107/#108/#111. Applying "unjudgeable → non-pass" to the protocol as a whole would instead hold #106 on a pause surface that #106 never delivers.

## Blockers and non-blocking notes

- **Non-blocking:** Must playtest tools (`DBG.*`, `TEL.*`) are not realized on this build — no UI surface in the deliverable.
- **Non-blocking:** no graphical run yet, so `screenshots/` is waiting for a re-run of `main@eea5f9d`.
- **Coverage gap (non-blocking):** no test constructs a 20×20 grid; `MarkGrid.new(20)` is untested although `SCH-mark-grid` F1 admits it.

## Situational tool

`PTD-crosses-and-fills` cites `SIT.3` (state dump). The dump is the seam-level equivalent (`snapshot()`, `filled_positions()`); it is written inline in [`notes.md`](notes.md) instead of into a separate file.
