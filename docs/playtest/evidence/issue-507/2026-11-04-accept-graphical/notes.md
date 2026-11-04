# Notes — issue #507 acceptance playtest

## What was judged

PR #510 sets `font_focus_color` and `font_hover_pressed_color` to Ink on `UI-result.C1`. The
reach is C1's `copy.back` on the result screen and the flows that build it:

1. **`PTU-play-puzzle` S3–S4, P1–P2** — solve `pack-003` by the shipped fills, wait out the morph,
   read C1 before touching it, then press it with a real pointer and return to the gallery.
2. **`PTU-mark-input` P1–P3** — `pack-004`: a real tap fills, a second tap clears, a secondary
   click crosses. The change touches no marking code; this confirms the screens it shares still work.

Everything else in [`specs/playtest/coverage.md`](../../../../../specs/playtest/coverage.md) is out of
reach of a theme-color override; the reasons are in [`manifest.md`](manifest.md#scope).

## How it was driven

`probe/probe_accept_507.gd` boots the shipped `shell.tscn` at 900×1200 under Xvfb, drives the real
screens and real pointer events, reads the drawn frame, and saves one PNG per judged state. It ran on
`main@4953c48` with `--debug-seams`, session `issue-507-accept`, on a fresh `user://` (isolated `HOME`).

Result: **20 checks passed, 0 failed**, 5 shots, exit 0.

## The label, judged from pixels

The player's symptom is mobile. On a touch device the shell focuses C1 at the end of the morph
(`Shell._on_result_morph_finished` → `_focus_first`), so C1 draws in its focused idle state —
`font_focus_color` — with no press. The probe confirms `button.has_focus()` and then samples every
pixel of C1's label box:

- darkest drawn pixel `(0.1059, 0.1569, 0.2)` — `PAL.K1` Ink (the palette's Ink color);
- fill `(0.9569, 0.9686, 0.9725)` — Paper, within the probe's 0.06 bar of `PAL.PAPER`;
- 30,552 samples inside the frame.

So the label is drawn, Ink on Paper, before any interaction. On the pre-fix tree the same state used
the engine's near-white focus color; the unit test PR #510 adds fails there, which verification
reported.

## Observations (non-blocking)

- **Touch release state.** `font_hover_pressed_color` covers the finger release on mobile. The probe
  drives mouse events, so this run does not separately shoot it; the unit test at `b104b65` pins it.
  The issue's reported state (focused, untouched) is shot.
- **Empty-clue auto-cross.** `pack-004` crosses a cell that is left clear when its clue line has no
  empty run there. The probe re-fills a cleared cell and re-checks the complement target at the
  moment of the gesture, so a product auto-cross is never read as a gesture fail.
- **Display.** No monitor on this host; Xvfb with Vulkan Forward+ on llvmpipe. Screenshots are the
  real frame texture, at the app's phone size.

## Reproduce

```sh
# copy probe/probe_accept_507.gd into game/, then:
HOME=<fresh-home> xvfb-run -a -s "-screen 0 1000x1300x24" \
    godot --path game -s res://probe_accept_507.gd -- --debug-seams \
    --session-id=issue-507-accept --build-id=main@4953c48 \
    --story-ids=PTU-play-puzzle,PTU-mark-input \
    --shot-dir=<run>/screenshots --run-folder=<run>
```
