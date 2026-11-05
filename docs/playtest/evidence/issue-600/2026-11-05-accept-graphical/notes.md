# Notes — issue #600 acceptance playtest (graphical gallery drag-vs-tap runs)

## What was judged

The deliverable tree `main@3aeedaf`: `game/` carries PR #606 (merged `6ec4077`). The only
later `game/` change is #607 (`puzzle.gd` focus colours + `test_puzzle_screen.gd`), which the
gallery tile and its `ScrollDragRelease` path do not touch. One probe
(`probe/probe_accept_600_layout.gd`, adapted from the committed #539 acceptance probe) ran
once per `PTU-gallery-layout` test viewport:

1. **Portrait, 360×640.** First-viewport geometry (2 columns, margin 18.5, gap 10, card
   153×236 at P (18, 147)), region fit, label containment, thumbnail square/full-width, the
   fresh-strip routing on `pack-001`, the seeded replay row on `pack-003`, then the tap legs
   and 229 C1 drag swipes to the last row. 300 PASS checks, exit 0.
2. **Landscape, 640×360.** 3 columns × 179 px beside a 32 px margin, the same legs, 163
   drags. 231 PASS checks, exit 0.

Each run enters its input the way a device does: `InputEventScreenTouch` / `ScreenDrag` /
mouse through `Input.parse_input_event`, so Godot's emulated mouse partner
(`DEVICE_ID_EMULATION`) arrives with every press, drag, and release. That pair is what the
defect was: the touch drag was consumed but the mirrored mouse release still reached C1.

### The tap legs (#600's acceptance criterion)

Both viewports pass all four:

- a finger tap on a card opens its puzzle (C1 once);
- a held drag that starts on C1 scrolls R2 and opens nothing;
- the **first tap after that drag** opens the tile under the finger — the press the drag
  cancelled is not left swallowing the next tap;
- a **device-0 mouse click** (a real mouse, not a touch mirror) still opens C1.

The scroll legs: portrait 229 drags, 0 mid-drag opens, scroll settles at 24151 against a max
of 24626, `pack-199` in frame at P (181, 386) size 153×236 and opens through C1; landscape 163
drags, 0 opens, scroll 17193 / max 17377, `pack-199` at P (227, 85) size 179×243 opens.

### Control on the pre-fix tree

The identical probe on `main@8fd1436` (no #606) fails exactly as reported: the drag opens a
puzzle and the tap after the drag does not open. On the deliverable both pass. So the pass is
the fix, not a harness blind spot. Control log: `control-prefix-portrait.log` (wiki).

### Deterministic citation

The passing record covering this `game/` tree is
[`docs/quality/evidence/issue-600/2026-11-05-verify/manifest.md`](../../../../quality/evidence/issue-600/2026-11-05-verify/manifest.md)
(`response-delay` 27.4 ms, `crash-free` open/solve/back/reset). Acceptance does not run
`deterministic`. No `llm-judge` axis applies.

## How the runs were made

Godot 4.7.2.stable on Linux x86_64, Mesa llvmpipe (GL compatibility) under `Xvfb` at
1280×1024; the window is resized to the test viewport before the shell's first layout. One
probe invocation per viewport with its own fresh `HOME` (`user://`):

```
godot --path game -s res://probe_accept_600_layout.gd -- --debug-seams \
    --width=360 --height=640 --session-id=issue-600-accept \
    --run-folder=<run folder> --shot-dir=<run folder>/screenshots
```

The probe was copied into `game/` for the runs and removed afterwards; the copy that ran is
kept in `probe/`. The host has no window manager, so the probe keeps every press ≥ 40 px from
the frame's top and ≥ 34 px from its bottom (the band a capture cannot reach reliably).

S5 state dumps: `state-portrait.json` / `state-landscape.json` on the wiki page; both have
`attempt: null`, i.e. no attempt was opened by a scroll — what P5 asserts.

## Non-blocking marks

- The story-id overlay (`story: portrait` / `story: landscape`) draws over R1's title in the
  captures: it is the `DBG.4` seam the protocol asks for, not game chrome.
- Thumbnails in the shipped pack mostly show the generic placeholder; the seeded `pack-003`
  draws its marked grid. Both are shipped behaviour, not this change.
- Landscape cards are taller than R2's band at 640×360, so a card's label row sits below the
  band on the first frame; P3/P4 are judged on the fully visible row after the scroll and the
  tap legs use the card's visible portion. This is pre-existing layout (#574's area), not
  this defect.
- Screenshot `02-*-scrolled` keeps the previous row clipped at the band's top by design (the
  capture is of the scrolled state at the grid's end, not a row-aligned snap).

## Blockers

None.
