# Notes — issue #645 graphical acceptance run

## What was judged

1. **Issue AC** — on mobile, the paper frame sits centered in R2: equal leftover
   margin on opposing sides (`frame_rect()`), and the board control still equals
   `BoardArea` (fills what R1/R3 leave; no shrink-to-fake-center).
2. **`PTU-play-puzzle` S1 / P3 / F3** — one framing at 10×10, 15×15, and 20×20 in
   portrait (900×1600), landscape (1600×900), and the protocol test viewports
   360×640 / 640×360; every clue fits its bar; no scroll/pan/zoom.
3. **Pause route** — puzzle → settings → back; framing unchanged.
4. **Marks** — 163 solution fills plus a cross; clues stay legible; cell interiors
   match Ink / Paper / Cross swatches.

## How it was driven

`probe_accept_645_graphical.gd` boots the shipped `shell.tscn` on a fresh `$HOME`,
sizes a borderless window to each judged frame, opens the sample through
`Shell.open_puzzle()`, switches the board to `PLATFORM_MOBILE`, and captures
`root.get_texture().get_image()` after the drawn frame.

Result: **124 checks passed, 0 failed**, 8 frames, exit 0.

## Margins observed

| Frame | Size | L / R | T / B |
|-------|------|-------|-------|
| portrait 10×10 | 900×1600 | 3 / 4 | 281 / 281 |
| portrait 15×15 | 900×1600 | 8 / 8 | 284 / 285 |
| portrait 20×20 | 900×1600 | 0 / 1 | 293 / 293 |
| landscape 20×20 | 1600×900 | 396 / 397 | 9 / 10 |
| viewport 360×640 | 360×640 | 6 / 7 | 105 / 105 |
| viewport 640×360 | 640×360 | 192 / 193 | 9 / 9 |

All pairs within the 1 px floor used by the unit test
`test_mobile_board_frame_is_centered_in_remaining_viewport`.

## Empty-board paint note

Sparse off-swatch samples on empty boards (AA at RULE edges) are logged and do not
block this layout acceptance. The marks shot requires full Ink/Paper/Cross match
and passed (0 off-swatch).

## Reproduce

See the manifest's **Reproduce** block.
