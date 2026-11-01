# Notes — issue #93 graphical acceptance

**Verdict:** every required protocol passed on `main@94e6c55`, and the graphical screenshots
are now in this folder. All four protocols were judged from this graphical run (none was left
waiting on a headless judgement).

## What was judged

The epic's stories (`L-solve`, `E-cell`, `E-clue`, `GS`, `E-puzzle`, `IN`, `J-play-puzzle`
open leg, `UI-puzzle`) intersect four protocols under `full` coverage. The probe re-runs them
through the real scenes — `shell.tscn`, `puzzle.tscn`, the gallery and result screens — and
the shipped `res://data/pack.json`. Gestures are synthesized `InputEventMouseButton` /
`InputEventKey` events pushed at the viewport, so `MarkInput` and the control hierarchy
resolve them exactly as a player's pointer and keys would. No gesture writes a grid, an
attempt field, or a progress record directly.

### `PTD-ready-and-marks` (`pack-000`)

- **S1 / P1.** Two taps during get-set-ready left the grid unchanged; the tool buttons were
  unavailable. After `finish_ready_beat()` the screen read `S1` with marks allowed, and
  fill → clear → cross each wrote through the cell.
- **P2.** `pack-000` rows 0 and 9 carry empty clues; the beat auto-crossed all ten cells of
  each line and the change committed.
- **S3 / P3.** A fill chosen to contradict a row's clue was written, the row's clue showed
  the error cue (`GS.row-error`), and the attempt stayed in `S1` — no fail state.
- **S4 / P3.** `UI-puzzle` C6 opened settings; `Shell` paused the attempt through O4, the
  `S3` state showed, and 90 frames later elapsed was still frozen. The input layer refused a
  stroke on the paused board. Settings' Back resumed through O5 (`S1` again), elapsed
  resumed ticking, and a tap committed again. `DBG.1` (F9) also paused and resumed.

### `PTD-crosses-and-fills` (`pack-001`)

- **S1 / P2.** All solution fills but one were placed, every other cell was crossed by the
  Cross tool, and the fully crossed board still read *not solved* — crosses are not fills.
- **S2 / P1.** The last required fill solved; the carried filled board opened `UI-result`
  on the first morph stage, and the morph reached Default with C1 drawn.

### `PTD-solve-and-pb` (`pack-002`)

- **S1 / P1.** First solve at 1:30: ever-completed true, attempt not in progress, record
  marks cleared and elapsed 0, PB 1:30.
- **S2 / P2.** A 2:25 replay kept PB 1:30; the gallery tile read `Done` / `Best 1:30`.
- **S3 / P3.** A 0:01 replay replaced the PB and cleared the marks again; a later replay
  longer than the new PB kept it.

### `PTU-play-puzzle` (`pack-002`, reset first)

- **S1–S4 / P1–P2.** Gallery → puzzle by tile click, the get-set-ready beat waited out on the
  real timer, the solve left for `UI-result`, the morph ran, C1 Back returned to the gallery,
  and the tile then read `Done` / `Best 0:01`. No stuck screen.

## Non-blocking observations

1. **Replay elapsed is additive.** The probe injects elapsed with `Attempt.advance`, which
   adds to the real tick; the recorded `2:25` therefore includes the injected 145 s plus the
   live play time. The protocol only requires "clearly longer / clearly shorter", which
   holds, so this is a capture detail, not a finding.
2. **Result reveal draws paper.** The result's Default stage shows an opaque picture slot and
   this build ships no stored pictures yet (#98 owns them); #208's own record covers that.
3. **`#203` (`PTU-mark-input`) is not required here.** Its `Cites` row is `IN` + `UI-puzzle`,
   but the protocol is still absent; the `IN` behaviour it would cover is judged in this run
   through `PTD-ready-and-marks` (S1–S2) and the hold recorded for #111.

## Reproduce

See [`manifest.md`](manifest.md#reproduce). The probe is
[`probe/probe_capture_93.gd`](probe/probe_capture_93.gd); copy it into `game/` for the run and
remove it afterward. It exits 0 when all 17 judged states were reached; this run reported
**133 passing checks** and `RESULT pass (17 shots)`.
