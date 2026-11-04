# Notes — issue #505 headless acceptance judgement

## What was judged

`PTU-play-puzzle` S1 / P3 / F3 for the framing change, at the three sample boards:

1. **S1 / P3** — the 10×10 sample (`pack-000`), then 15×15 (`pack-010`), then 20×20 (`pack-180`),
   opened from the gallery on the shipped shell. R2 judged: framed board inside the board area, its
   padding all round, every row and column clue drawn inside its bar, no clue painting outside the
   frame, no scroll container, no scale.
2. **Pause route** — the same 20×20 board through the app's own pause intent (puzzle → settings →
   back), which must pause and resume without changing R2.
3. **Marks overlay** — a fill and a cross in two cells, to see the clues stay legible next to marks.
4. **Landscape** — the app's stored/default orientation is portrait and the platform request for
   landscape is `DisplayServer.SCREEN_LANDSCAPE`; the frame itself is not re-drawn.

## How it was driven

`probe_accept_505.gd` boots the shipped `shell.tscn` once at 900×1600 (the 9:16 portrait host of the
previous graphical runs) on a fresh `$HOME`, opens each sample through `Shell.open_puzzle()`, and
switches the opened board to `PuzzleBoard.PLATFORM_MOBILE` — the public seam
`game/test/test_puzzle_board.gd` uses, because the ship scene picks the desktop rule on a Linux host.

Result: **63 checks passed, 0 failed**, 5 frames, exit 0. GUT `game/test/test_puzzle_board.gd`:
**8/8 passing** on this tree.

## Why the viewports and landscape are not driven

`game/project.godot` sets a 900 px minimum window width (and Godot's desktop window enforces its
minimum on start), so a 360×640 or 640×360 frame cannot be produced by the runtime here — an earlier
attempt to force `root.size` handed the scene a layout the tests' `_layout_at()` also cannot make
below that minimum. The protocol's per-viewport and landscape legs therefore stay with the graphical
re-run, which is owed anyway.

## Observation: cell painting

In the captured frames the clue text and the board's frame lines were present but the cell borders
and fills were not distinguishable. `PuzzleCell` draws in `_draw()` only and is a plain `Control`. The
unit suite never asserts a pixel, and `game/` has not changed since the verification commit, so this
is recorded for the graphical re-run to settle — this run does not file a defect for it.

## Reproduce

See the manifest's **Reproduce** block.

## Blocker, concretely

`game/project.godot` sets no window size of its own (the `[display]` block only carries the handheld
orientation lock), and the desktop window enforces a floor of about 900 px on start. An attempt to
force `root.size` below it handed the scene a layout the tests' `_layout_at()` cannot produce either
(a different cell side from `ACHIEVED_CELL`), so the 360×640 and 640×360 protocol frames are not
driveable from this host. Only a device, an emulator, or a build that changes the window floor can
reach them; headless acceptance can judge R2's composition at a larger frame but not the two protocol
viewports.
