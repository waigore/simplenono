# Notes — issue #562 acceptance playtest

Build `main@6ec4077`, Godot 4.7.2.stable, Vulkan Forward+ over llvmpipe under Xvfb,
900×1200, one fresh `user://` (`HOME=/tmp/562-home2`) shared by three processes. The
ready edge is unchanged since the #562 merge `3288a38` (the later presentation commits
in `3288a38..6ec4077` touch the gallery only).

## What was judged

- **`PTD-ready-and-marks` on `pack-015`** (15×15, empty clue rows 0/1/2/12/13/14 and
  columns 0/9/14 — 117 empty-clue cells, read from the shipped `row-clues`/`col-clues`,
  not from the solution). A mark attempted during get-set-ready did not stick. After
  ready the board held 0 crosses and 0 fills, every empty-clue cell was clear, the
  attempt read `not_started`, and the stored record was not in progress — the exact P2
  rule this issue changes. The first fill then set `in_progress`. Fill → clear →
  complement-as-cross matched `DBG.2` on every judged cell. A wrong fill was accepted,
  did not solve, and left the attempt playable. Pause froze elapsed at 2 s, blocked a
  pointer mark, and resume restored usability.
- **`PTU-mark-input` on `pack-018`**: the board opened with no auto-cross; fill, clear,
  complement, and a 3-cell drag-paint each matched `DBG.2`. Three of the board's 15
  empty-clue cells were later marked by the run itself (the drag run crossed into row 0);
  the other 12 stayed clear, as the rule requires.
- **Cross-first start on `pack-016`**: ready alone left the attempt `not_started`; the
  first cross through the Cross tool marked the cell and set `in_progress`. This covers
  the half of AC 3 the fill path does not.
- **`PTD-crosses-and-fills` on `pack-183`** (20×20, twenty empty clue lines): all 295
  non-solution cells were crossed by real pointer input, 232 of them on empty-clue lines.
  The fully crossed board did not solve; the solution fills solved it once, reached the
  result screen, and set `ever_completed`.
- **`PTU-leave-resume` on `pack-019`** (15×15, nine empty clue lines): three correct
  fills and elapsed 7 s, then Leave. The tile read `In progress`, the stored record was
  `in_progress` at elapsed 7 with **0** crosses. The app then exited. On relaunch the
  tile still read In progress; reopening through `UI-gallery.C1` and waiting through the
  beat restored exactly the same three fills, kept `in_progress`, resumed elapsed at 7
  and ticked it to 11, with **0** crosses on the board and all empty-clue cells clear —
  reopen adds no auto-cross. Pausing with `UI-puzzle.C6` (settings showing, elapsed 11)
  and exiting, then relaunching and reopening, restored the same marks and elapsed 11,
  ticking to 15.

## Non-blocking marks

- The gallery drag fix on `main` (`6ec4077`, #606) landed after this issue's merge and
  touches only `gallery_tile.gd`, `scroll_drag_release.gd`, and `test_touch_input.gd`; it
  cannot move the ready edge or the restore path, and the reopen-through-C1 path used
  here still opens the tile. Not a finding.
- The resume and pause phases each write `logs/state-pack-019.json` (same puzzle id); the
  file kept in the wiki `logs/` folder is the pause-quit one. Both are also described in
  the logs themselves (`capture-resume.log`, `capture-pause.log`).
- `pack-015` was left in progress by the ready/marks run (one cross and one wrong fill).
  It is a scratch board for this run; the issue's AC do not require it to be clean.

## Playtest tooling used

`DBG.1` (pause/resume), `DBG.2` (inspect, after every judged gesture), `DBG.3`
(`open_puzzle`), `DBG.4` (story-ID overlay on in every screenshot), `TEL.1`–`TEL.5`
(every session line carries session id, build id, story id, and outcome). `SIT.3` was used
for the state dumps in `logs/` on the wiki. No Situational tool beyond `SIT.3` was
needed.
