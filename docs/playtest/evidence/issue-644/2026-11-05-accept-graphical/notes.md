# Notes — issue #644 acceptance playtest

## What was judged

PR #655 pins `font_color` to Ink on `UI-puzzle`'s R1 `ElapsedLabel` (`copy.elapsed`).
The measured reach is the puzzle screen's timer visibility and the flows that build,
pause, leave, and reopen it:

1. **Issue AC** — open `pack-004`, read the drawn elapsed label in get-set-ready and
   again once Ready with a ticking `m:ss`; theme `font_color` and glyph pixels must be
   Ink on Paper.
2. **`PTD-ready-and-marks` S1–S4 / P1, P3** — the beat blocks the mark; fill → clear →
   cross apply once ready; C6 pauses (elapsed frozen ≥ 2 for 1.5 s, marks blocked) and
   Back resumes.
3. **`PTU-mark-input` P1–P3** — a real tap fills, a second tap clears, complement crosses.
4. **`PTU-leave-resume` S2–S3 / P1–P2** — C1 leave → tile In progress → reopen restores
   the mark and resumes elapsed; R1 timer still Ink.

Out-of-scope protocols and reasons: [`manifest.md`](manifest.md#scope).

## How the timer was judged

`probe/probe_accept_644.gd` boots the shipped `shell.tscn` at 900×1200 on Metal, drives
the real screens with real pointer events, reads the drawn frame (`root.get_texture()`),
and samples every pixel inside `ElapsedLabel`'s global rect. The fill must be Paper and
the glyphs Ink. It also asserts the Label's theme `font_color` is Ink (not Paper). It ran
on `d356b1fc` with `--debug-seams`, session `issue-644-accept`, on a fresh `user://`.

Result: `capture: RESULT pass (7 shots, 0 checks failed)`, exit 0.

Readings (`screenshots/01-puzzle-elapsed-get-set-ready.png`):

- darkest drawn pixel `(0.1059, 0.1569, 0.2)` — `PAL.K1` / `PAL.C2` Ink;
- fill `(0.9569, 0.9686, 0.9725)` — `PAL.PAPER`;
- 2,318 samples of the label box inside the frame;
- theme `font_color` `(0.1059, 0.1569, 0.2, 1.0)`.

## Control on the pre-fix tree

The same open-path reading on `ba100182` (parent of the #655 squash) gives theme
`font_color=(1, 1, 1, 1)` and a darkest label pixel of Paper
`(0.9569, 0.9686, 0.9725)` with lightest white `(1, 1, 1)` — no Ink glyphs on the Paper
chrome, the invisible timer the defect reports. The control's own run log is on the wiki
as `logs/control-prefix-capture.log`.

## Harness caveats (not product findings)

- **Pause sample timing.** Elapsed for the freeze check is read after pause is confirmed,
  not before the C6 click: a Ready tick can land between a pre-click sample and O4, which
  is not a product miss. After confirmation, elapsed held at 2 for 1.5 s.
- **Scroll.** At 900×1200 the settings page shows C3 Back below the fold, and the gallery
  may need a drag to reach `pack-004`'s tile. Those legs use `Shell.close_settings()` and
  `GalleryScreen.activate_tile()` — the screens' own routing — so the judged state is
  reached without a scroll neither protocol asks for.
- **Clear resets elapsed.** PS1.6: clearing the last fill returns the attempt to not
  started with elapsed 0. The probe banks ~2 s after the complement cross before pausing
  so the freeze is judged against a non-zero `GS.solve-elapsed`.

## Reproduce

```sh
# copy probe/probe_accept_644.gd into game/, then:
HOME=<fresh-home> godot --path game -s res://probe_accept_644.gd -- --debug-seams \
    --session-id=issue-644-accept --build-id=main@d356b1fc \
    --story-ids=PTD-ready-and-marks,PTU-mark-input,PTU-leave-resume \
    --shot-dir=<run>/screenshots --run-folder=<run>
```
