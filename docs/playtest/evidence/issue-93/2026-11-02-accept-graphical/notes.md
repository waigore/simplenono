# Notes — issue #93 graphical acceptance

**Verdict:** every required protocol passed on `main@94e6c55`, and the graphical screenshots
are now in this folder. All four protocols were judged from this graphical run (none was left
waiting on a headless judgement). Scope is in [`criteria.md`](criteria.md) and per-row outcomes
in [`results.md`](results.md).

## How it was judged

The probe re-runs the four protocols through the real scenes — `shell.tscn`, `puzzle.tscn`,
the gallery and result screens — and the shipped `res://data/pack.json`. Gestures are
synthesized `InputEventMouseButton` / `InputEventKey` events pushed at the viewport, so
`MarkInput` and the control hierarchy resolve them exactly as a player's pointer and keys
would. No gesture writes a grid, an attempt field, or a progress record directly.

Per-protocol detail, row by row:

- **`PTD-ready-and-marks` (`pack-000`).** Taps during get-set-ready changed nothing; after
  `finish_ready_beat()` the screen read `S1` and fill → clear → cross each wrote through the
  cell. Rows 0 and 9 carry empty clues and were auto-crossed whole on the beat. A fill
  contradicting its row's clue cued `GS.row-error` and stayed in `S1` — no fail state.
  `UI-puzzle` C6 opened settings; `Shell` paused through O4, and 90 frames later elapsed was
  still frozen and strokes refused. Back resumed through O5; `DBG.1` (F9) also paused and
  resumed.
- **`PTD-crosses-and-fills` (`pack-001`).** All solution fills but one were placed and every
  other cell crossed; the fully crossed board still read *not solved*. The last required fill
  solved, and the carried board opened `UI-result` on its first morph stage.
- **`PTD-solve-and-pb` (`pack-002`).** The 1:30 first solve set ever-completed true, cleared
  marks and elapsed, and stored PB 1:30. A 2:25 replay kept it (tile `Done` / `Best 1:30`); a
  0:01 replay replaced it, and a later longer replay kept that PB.
- **`PTU-play-puzzle` (`pack-002`, reset first).** Gallery → puzzle by tile click, the
  get-set-ready beat waited out on the real timer, the solve left for `UI-result`, the morph
  ran, C1 Back returned to the gallery, and the tile read `Done` / `Best 0:01`.

## Non-blocking observations

1. **Replay elapsed is additive.** The probe injects elapsed with `Attempt.advance`, which
   adds to the real tick; the recorded `2:25` therefore includes the injected 145 s plus live
   play time. The protocol only requires "clearly longer / clearly shorter", which holds, so
   this is a capture detail, not a finding.
2. **Result reveal draws paper.** The result's Default stage shows an opaque picture slot and
   this build ships no stored pictures yet (#98 owns them); #208's own record covers that.
3. **`#203` (`PTU-mark-input`) is not required here.** Its `Cites` row is `IN` + `UI-puzzle`,
   but the protocol is still absent; the `IN` behaviour it would cover is judged in this run
   through `PTD-ready-and-marks` (S1–S2) and the hold recorded for #111.

## Reproduce

See [`manifest.md`](manifest.md#reproduce). The probe is
[`probe/probe_capture_93.gd`](probe/probe_capture_93.gd); copy it into `game/` for the run and
remove it afterward. It exits 0 when all 17 judged states were reached; this run reported
**133 passing checks** and `RESULT pass (17 shots)`. The screenshot index is
[`screenshots.md`](screenshots.md).
