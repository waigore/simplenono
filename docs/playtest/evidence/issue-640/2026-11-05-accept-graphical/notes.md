# Notes — issue #640 acceptance playtest (graphical gallery R2 fling coast)

## What was judged

Deliverable tree `main@cfed28ea` (PR #656). Probe
(`probe/probe_accept_640_layout.gd`, adapted from the #600 layout probe) ran once per
`PTU-gallery-layout` test viewport, plus a mid-scroll R2 fling coast check for the
Experience intent in `specs/ux/screens/gallery.md`.

1. **Portrait, 360×640.** First-viewport geometry, #640 fling (travelled 905 px vs engine
   ceiling 405 at friction 400), P5 tap/drag/mouse legs, P6 strip + replay row, 235 C1
   drags to the last row. 307 PASS checks, exit 0.
2. **Landscape, 640×360.** Same legs; fling travelled 904 px; 163 drags. 232 PASS checks,
   exit 0.

GUT on the same build: `test_gallery_r2_scroll.gd` 3/3 and `test_touch_input.gd` 10/10.

### Host note (P1 MarginContainer)

On macOS Metal the `Margin` node’s global rect overflows the gallery by ~8 px when the
vertical scrollbar is present (also reproduced on the pre-#640 tree). Chrome and tiles
still fit; the probe judges P1 from those, with a visible gutter floor of 8 px
(`MIN_PAGE_MARGIN`). Linux Xvfb acceptance runs for earlier gallery issues did not see
this overflow.

## How the runs were made

Godot 4.7.2.stable on macOS arm64 (Metal). Borderless window sized to the test viewport.
One probe invocation per viewport with its own fresh `HOME` (`user://`):

```
godot --path game -s res://probe_accept_640_layout.gd -- --debug-seams \
    --width=360 --height=640 --session-id=issue-640-accept \
    --run-folder=<run folder> --shot-dir=<run folder>/screenshots
```

The probe was copied into `game/` for the runs and removed afterwards; the copy that ran
is kept in `probe/`.

## Quality

Deterministic and llm-judge: N/A for this feel/friction-only deliverable (see manifest).

## Blockers

None.
