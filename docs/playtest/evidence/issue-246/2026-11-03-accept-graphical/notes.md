# Notes — issue #246 graphical acceptance run

Build `main@f5fa471` (PR #366 squash), Godot 4.7.2.stable, graphical on macOS arm64 (Metal),
900×1200. Session `issue-246-accept`. Every observation below is from this run's console and
screenshots; `DBG.2` was read after each mark gesture.

## Setup

- The run starts from a cleared record: the probe passes `DBG.3` `reset_puzzle` over every
  definition before the first shot, so shot 01 is a fresh gallery.
- The pack loads 200 entries and rejects none.
- `expect.json` was built first by `tools/expectations.py` from the committed pixel files and
  pack rows in the deliverable tree. It re-implements the fill rule and a line solver and does
  not import `.github/scripts/puzzle_derive.py`.

## `PTU-play-puzzle` / `PTD-solve-and-pb` / `CMP-shell` on `pack-054`

1. `pack-054` opens through `DBG.3`; the ready beat is shown (shot 02).
2. `finish_ready_beat()` ends it; `marks_allowed()` is true.
3. A near-solve record with 62 of 63 committed fills is written through `CTR-pack` O5, then the
   puzzle is reopened. The board shows the two 7-wide masses with one lower-right cell missing
   (shot 03).
4. The last correct fill fires `attempt.solved` once and the shell switches to `UI-result`.
   `result_screen().finish_morph()` ends the reveal on the deciding frame (shot 04).
5. Both `picture_id` and `pixel_picture_id` resolve through the shell's picture provider.
6. Back returns to the gallery; the tile reads `Done`, `Best 1:00`, with its picture thumbnail
   (shot 05). Completion count is 1.

## `PTU-mark-input` on `pack-055`

`pack-055` is mostly empty-clue rows/columns, so the board arrives auto-crossed in many places;
the probe picks cells the board still shows Clear, per the protocol's P1–P4 needs.

| Step | Observed |
|------|----------|
| Tap a clear cell with Fill selected | drawn mark `FILL`; `DBG.2` `fill` |
| Tap the same cell again | drawn mark `CLEAR`; `DBG.2` `clear` |
| Complement (right click) on a clear cell | drawn mark `CROSS`; `DBG.2` `cross` |
| Drag across a 3-cell clear run with Cross selected | all three cells `CROSS`; `DBG.2` agrees on each |

Shot 06 records the board after the four gestures. Leaving the puzzle returns to the gallery
with 1 completed, so unsolved marks did not complete `pack-055` (shot 07).

## `PTD-crosses-and-fills` on `pack-056` and `pack-057`

- `pack-056`: the probe first crosses every non-solution cell through real pointer events — 149
  of 225 cells (shot 10) — then places its 76 committed fills. The solve lands exactly once on
  the last committed fill, and the result screen is reached. A wrong fill set or a clue that
  disagrees with the pixel would leave the board unfinished.
- `pack-057`: all 60 committed fills are placed on the empty board; the last one solves once
  and reaches the result screen (shot 11). It is the slice's single-subject puzzle; the result
  frame shows its E-shaped mass.
- Both read `ever_completed: true` through `DBG.2` afterwards.

The gallery ends with 3 completed (`pack-054`, `pack-056`, `pack-057`), matching the three
solved boards.

## Out of scope, with reason

- `PTU-gallery-reset` S1–S3: the reset confirm dialog is `#96` work and is not changed by this
  slice. Its first-open blank card is the pre-existing defect #380, separately owned. This run
  does not judge that dialog, and no bar item depends on it.
- `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings`: not reachable from picture data or
  from the four rebuilt rows.
- The pack-wide subject mix and regeneration record are #294's, not this slice's.
