# Notes — issue #250 graphical acceptance run

Build `main@4c0206e` (PR #376 squash), Godot 4.7.2.stable, graphical on macOS arm64 (Metal),
900×1200. Session `issue-250-accept`. Every observation below is from this run's console and
screenshots; `DBG.2` was read after each mark gesture.

## Setup

- The run starts from a cleared record: the probe passes `DBG.3` `reset_puzzle` over every
  definition before the first shot, so shot 01 is a fresh gallery.
- The pack loads 200 entries and rejects none.
- `expect.json` was built first by `tools/expectations.py` from the committed pixel files and
  pack rows in the deliverable tree. It re-implements the fill rule and a line solver and does
  not import `.github/scripts/puzzle_derive.py`.

## `PTU-play-puzzle` / `PTD-solve-and-pb` / `CMP-shell` on `pack-070`

1. `pack-070` opens through `DBG.3`; the ready beat is shown (shot 02).
2. `finish_ready_beat()` ends it; `marks_allowed()` is true.
3. A near-solve record with 84 of 85 committed fills is written through `CTR-pack` O5, then the
   puzzle is reopened. The board shows the pyramid with its apex missing (shot 03).
4. The last correct fill fires `attempt.solved` once and the shell switches to `UI-result`.
   `result_screen().finish_morph()` ends the reveal on the deciding frame (shot 04). The stored
   square draws as the expected pyramid: 4-wide base rows tapering to a single apex cell.
5. Both `picture_id` and `pixel_picture_id` resolve through the shell's picture provider.
6. Back returns to the gallery; the tile reads `Done`, `Best 1:00`, with its picture thumbnail
   (shot 05). Completion count is 1.

## `PTU-mark-input` on `pack-071`

Fill, clear, complement, and drag were each sent as real input events over real cells, and
`DBG.2` agreed with the drawn mark in every case (shots 06–07). After leaving the puzzle the
gallery still showed `pack-071` in progress, not completed, so unfinished marks do not
complete a puzzle.

Note on `pack-071`: its pixel is a genuinely holed multi-subject board (4 masses, 8 holes), and
its row and column clues are symmetric. The board renders and plays normally; symmetry is a
look property, not a correctness one, and the shared picture bar's look item was judged
`Pass` in the catalog review.

## `PTD-crosses-and-fills` on `pack-072` and `pack-073`

`pack-072` was played with **every** non-solution cell preceded as a cross (157 of 225), then
its 68 committed fills were placed (shot 10). The win landed once and set ever-completed, so
crosses are non-fills and the fill set is exactly the committed row. `pack-073` was solved from
its 62 committed fills (shot 11, the result frame). Both reached the result screen and
`ever_completed` was set in the `DBG.1` record.

## Judgement

Every protocol in scope passed. There is no game or interface failure to report, so no defect
was filed. The two observations worth recording are not failures: `pack-071` is symmetric
(look only, catalog review `Pass`), and the first-open blank gallery card in shot 01 area is
the pre-existing defect #380, owned outside this slice.
