# Notes — issue #252 graphical acceptance run

Build `main@c41c104`, Godot 4.7.2.stable, graphical on macOS arm64 (Metal), 900×1200.
Session `issue-252-accept`. Every observation below is from this run's console and
screenshots; `DBG.2` was read after each mark gesture.

## Setup

- The run starts from a cleared record: the probe passes `DBG.3` `reset_puzzle` over every
  definition before the first shot, so shot 01 is a fresh gallery.
- The pack loads 200 entries and rejects none.
- `expect.json` was built first by `tools/expectations_252.py` from the committed pixel files
  and pack rows in the deliverable tree. It re-implements the fill rule (alpha over white,
  `Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, `Y < 128`) and its own line solver; it does
  not import `.github/scripts/puzzle_derive.py`.
- `git diff ee57b38 c41c104 -- game/assets/puzzle-pictures game/data/pack.json` is empty: the
  four puzzles this run exercises are the ones PR #372 (squash `ee57b38`) landed. Later
  slices only added their own rows.

## `PTU-play-puzzle` / `PTD-solve-and-pb` / `CMP-shell` on `pack-078`

1. `pack-078` opens through `DBG.3`; the ready beat is shown (shot 02).
2. `finish_ready_beat()` ends it; `marks_allowed()` is true.
3. A near-solve record with 83 of 84 committed fills is written through `CTR-pack` O5, then the
   puzzle is reopened (shot 03: the top bar plus the stepped block, one cell short).
4. The last correct fill fires `attempt.solved` once and the shell switches to `UI-result`.
   `result_screen().finish_morph()` ends the reveal on the deciding frame (shot 04: the calm
   cool square, a light frame with dark blocks).
5. Both `picture_id` and `pixel_picture_id` resolve through the shell's picture provider.
6. Back returns to the gallery; the tile reads `Done` with its picture thumbnail (shot 05).
   Completion count is 1.

## `PTU-mark-input` on `pack-079`

`pack-079` is mostly empty-clue rows/columns, so the board arrives auto-crossed in many places;
the probe picks cells the board still shows Clear, per the protocol's P1–P4 needs.

| Step | Observed |
|------|----------|
| Tap a clear cell with Fill selected | drawn mark `FILL`; `DBG.2` `fill` |
| Tap the same cell again | drawn mark `CLEAR`; `DBG.2` `clear` |
| Complement (right click) on a clear cell | drawn mark `CROSS`; `DBG.2` `cross` |
| Drag across a 3-cell clear run with Cross selected | all three cells `CROSS`; `DBG.2` agrees on each |

Shot 06 records the board after the four gestures; the clue gutter shows the slice's clue
lists (rows `3 / 5 / 5,4 / 5,5 …`, columns `9 / 10 / 11 / 11 / 11` with empty ends). Leaving the
puzzle returns to the gallery with 1 completed, so unsolved marks did not complete `pack-079`
(shot 07).

## `PTD-crosses-and-fills` on `pack-080` and `pack-081`

- `pack-080`: the probe first crosses every non-solution cell through real pointer events — 153
  of 225 cells (shot 08) — then places its 72 committed fills. The solve lands exactly once on
  the last committed fill, and the result screen is reached. A wrong fill set or a clue that
  disagrees with the pixel would leave the board unfinished.
- `pack-081`: all 90 committed fills are placed on the empty board; the last one solves once
  and reaches the result screen (shot 09). It is the slice's other multi-subject puzzle; the
  result frame shows two upright blocks with a clear channel between them.
- Both read `ever_completed: true` through `DBG.2` afterwards.

The gallery ends with 3 completed (`pack-078`, `pack-080`, `pack-081`), matching the three
solved boards.

## Subject classes (bar item 6 input)

Measured on the committed pixels, connected masses of the fill set and enclosed background
holes:

| Puzzle | Issue's class (index mod 10) | Measured |
|--------|------------------------------|----------|
| pack-078 | multi-subject and/or holed | one mass of 84 with 7 enclosed holes |
| pack-079 | multi-subject and/or holed | two masses, 52 + 39, no holes |
| pack-080 | single-subject | one mass of 72 with 1 enclosed hole |
| pack-081 | multi-subject and/or holed | two masses, 45 + 45, no holes |

`pack-078` reads as one connected bar-and-block silhouette with holes between the blocks, which
sits on the "and/or holed" side of the issue's class. As with `pack-077` on #251, this is
recorded for the pack-wide mix on #294, not judged as a fail here: the catalog prompt states the
issue's class, the pixel is in band, unique, and byte-reproducible, and the silhouette reads at
15×15.

## Out of scope, with reason

- `PTU-gallery-reset` S1–S3: the reset confirm dialog is `#96` work and is not changed by this
  slice. This run does not judge that dialog, and no bar item depends on it.
- `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings`: not reachable from picture data or
  from the four rebuilt rows.
- The pack-wide subject mix and regeneration record are #294's, not this slice's.
