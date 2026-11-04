# Notes — issue #505 graphical acceptance run

## What was judged

`PTU-play-puzzle` S1 / P3 / F3 — the mobile framing protocol — on the displayed frame:

1. **Portrait** at 900×1600: the 10×10 sample (`pack-000`), then 15×15 (`pack-010`), then 20×20
   (`pack-180`), each opened from the gallery on the shipped shell and switched to the mobile
   framing rule through `PuzzleBoard.set_platform()`. R2 judged: the framed board inside the board
   area, its padding all round, every row and column clue drawn inside its bar, no clue painting
   outside the frame, no scroll container, no scale.
2. **Pause route** — the 20×20 board through the app's pause intent (puzzle → settings → back).
3. **Marks** — the whole solution filled (130 Ink cells) plus a cross in the first clear cell, to see
   the clues stay legible next to marks, and to put Ink in front of the pixel check.
4. **Landscape** at 1600×900 — the window really turned, then the same 20×20 board re-judged.
5. **Protocol test viewports** 360×640 and 640×360, 20×20 — the tightest frames the protocol names.

## How it was driven

`probe_accept_505_graphical.gd` boots the shipped `shell.tscn` on a fresh `$HOME`, sizes the window
to each judged frame (`root.size` plus `DisplayServer.window_set_size`), opens the sample through
`Shell.open_puzzle()`, switches the board to `PLATFORM_MOBILE`, and captures
`root.get_texture().get_image()` after the frame that was actually drawn.

Result: **112 checks passed, 0 failed**, 8 frames, exit 0.

## The headless run's two open points

**Cell painting — closed, no defect.** The headless run could not tell whether cells painted, and
filed nothing. This run sampled three by three interior points of every cell in every frame and
matched them against the palette's luminance: every sample was Paper C1, Rule C4, Ink C2 or Cross
C3, no sample was off the palette, and every clear cell interior was Paper. In the marks shot, 130
filled cells are Ink and the cross cell shows Cross. The observation belonged to the headless
frames; the displayed frames show the cells painting.

**Viewports — reachable after all.** The headless run reported 360×640 and 640×360 as not driveable
through Godot's minimum window width. With the root window size set directly the window gave both
frames exactly, and both were judged and captured (board 328×512 and 608×232, 7 px clue faces, 14
and 9 px cells). On the 640×360 frame the 9 px cells sit one pixel above `PuzzleBoard.MIN_CELL_SIZE`
(8 px) and the clue face is at the `UIS.T1` 7 px floor: the tightest framing the protocol allows,
and it still fits — no clue clipped, no overflow.

## Reproduce

See the manifest's **Reproduce** block. The probe lives in `../probe/` and runs from the repo root
with `--path game`, so nothing is written into `game/` beyond its own transient `.godot` cache.
