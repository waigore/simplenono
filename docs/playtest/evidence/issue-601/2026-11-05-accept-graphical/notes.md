# Notes — issue #601 acceptance playtest

## What was judged

PR #607 sets `font_focus_color` (and `font_hover_pressed_color` on the chrome) to Ink on
`UI-puzzle`'s C1, C6, and C3–C5. The measured reach is the puzzle screen's label states and
the flows that build and leave it:

1. **`PTU-leave-resume` S1–S3 / P1–P2** — open `pack-004`, read C1 before touching it in
   get-set-ready and again once ready, try a mark during the beat, then a real C1 press to
   the gallery, the tile reading In progress, and a reopen through the tile that restores
   the committed mark and elapsed.
2. **`PTD-ready-and-marks` S1–S4 / P1, P3** — the beat blocks the mark, fill → clear → cross
   apply once ready, C6 pauses (elapsed frozen, marks blocked) and Back resumes.
3. **`PTU-mark-input` P1–P3** — a real tap fills, a second tap clears, complement crosses.
4. **`UI-puzzle` label states** — C1, C6, C3–C5 pixels sampled before any press.

Out-of-scope protocols and reasons: [`manifest.md`](manifest.md#scope).

## How the labels were judged

`probe/probe_accept_601.gd` boots the shipped `shell.tscn` at 900×1200 under Xvfb, drives
the real screens with real pointer events, reads the drawn frame (`root.get_texture()`), and
samples every pixel inside each button's label box. The fill must be Paper or Ink, and the
glyphs must be Ink (or Paper on the selected tool's Ink fill). It ran on `ed91db1` with
`--debug-seams`, session `issue-601-accept`, on a fresh `user://`.

Result: `capture: RESULT pass (8 shots, 0 checks failed)`, exit 0.

Readings (`screenshots/01-puzzle-leave-get-set-ready.png`:

- darkest drawn pixel `(0.1059, 0.1569, 0.2)` — `PAL.K1` Ink;
- fill `(0.9569, 0.9686, 0.9725)` — `PAL.PAPER`;
- 3,040 samples of C1's label box inside the frame.

## Control on the pre-fix tree

The same focused-idle reading on `6ec4077` (one commit before the deliverable) gives
`font_focus_color=(0.95, 0.95, 0.95, 1.0)` and a darkest label pixel of
`(0.949, 0.949, 0.949)` on the same Paper fill — the invisible "Leave" the defect reports.
The whole-run probe on the pre-fix tree also passed every label reading, because it
re-asserts focus on each control before sampling; the focused-idle control reading is the
leg that shows the defect, and the post-fix tree reads Ink for it. The control's own run
log is on the wiki as `logs/control-prefix-capture.log`.

## Harness caveats (not product findings)

- **Frame rate.** This host renders 900×1200 on llvmpipe at about 20 fps, so the 500 ms
  get-set-ready beat can end on its timer mid-frame. The beat check is therefore the
  attempt status (a blocked mark leaves it not started), and elapsed comparisons use
  wall-clock waits.
- **Scroll.** At 900×1200 the settings page shows C3 Back below the fold, and the 20-card
  gallery needs a drag to reach `pack-004`'s tile. Those two legs use `Shell.close_settings()`
  and `GalleryScreen.activate_tile()` — the screens' own C3/C1 routing — so the judged state
  is reached without a scroll neither protocol asks for. Tile C1's pointer path is
  `PTU-gallery-layout`'s and was accepted for #600 on the same build family.
- **Touch release.** `font_hover_pressed_color` is pinned in the same change and covered by
  the unit test at `ed91db1`; this run drives pointer presses, so it does not separately
  shoot the held-finger state.

## Reproduce

```sh
# copy probe/probe_accept_601.gd into game/, then:
HOME=<fresh-home> xvfb-run -a -s "-screen 0 1000x1300x24" \
    godot --path game -s res://probe_accept_601.gd -- --debug-seams \
    --session-id=issue-601-accept --build-id=main@ed91db1 \
    --story-ids=PTU-leave-resume,PTD-ready-and-marks,PTU-mark-input \
    --shot-dir=<run>/screenshots --run-folder=<run>
```
