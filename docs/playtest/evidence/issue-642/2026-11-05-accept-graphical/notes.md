# Notes — issue #642 acceptance playtest

## What was judged

PR #657 replaces the unsolved gallery-tile mini filled-grid glyph with a simple RULE
box and a centered Ink "?" (`gallery_thumb.gd` / `UI-gallery` US1.3). The measured
reach is the gallery R2 placeholder and the status / PB / Reset facts that must stay:

1. **Issue AC / US1.3** — `pack-000` (Not started) and `pack-001` (In progress, never
   completed) draw the placeholder: Paper fill, Ink "?", RULE inset frame; Ink fraction
   sparse (not a filled mini-grid); `shows_picture=false`.
2. **Issue AC / US1.2** — `pack-003` ever-completed with PB draws the solution thumbnail
   (`shows_picture=true`), Done, Best 1:01.
3. **Issue AC / status · PB · C2** — fresh withdraws Reset; in-progress and
   ever-completed keep it; Best only when set.
4. **`PTU-gallery-layout` S1 / P1, P2, P4** — 360×640 first viewport: page margin, 2
   columns, square thumbnail region.
5. **`PTU-gallery-reset` S1 allowedness** — C2 availability matches the rules above
   (no Cancel/Confirm wipe in this run).

Out-of-scope protocols and reasons: [`manifest.md`](manifest.md#scope).

## How the placeholder was judged

`probe/probe_accept_642.gd` boots the shipped `shell.tscn` at 360×640 on Metal, seeds a
fresh progress document (`pack-001` in progress; `pack-003` ever-completed with PB),
and samples every pixel inside each unsolved tile's inset thumb rect. The fill must be
Paper, the darkest glyph Ink, Rule pixels present on the inset frame, and Ink fraction
≤ 0.22 so a filled mini-grid would fail. It ran on `main@2f905b80` (gallery draw path
identical to deliverable `a988a0c7`) with `--debug-seams`, session `issue-642-accept`.

Result: `capture: RESULT pass (4 shots, 0 failed)`, exit 0.

Readings (`pack-000` / `pack-001` inset):

- darkest `(0.1059, 0.1569, 0.2)` — Ink;
- lightest `(0.9569, 0.9686, 0.9725)` — Paper;
- 223 Ink pixels (fraction 0.024), 406 Rule pixels;
- 9,409 samples of the inset box.

## Specs and mockups (static)

- `specs/ux/screens/gallery.md` R2 and `specs/ux/stories/screens/gallery.md` US1.3 state
  the locked simple box + centered question mark.
- `MC.gallery-mobile` / `MC.gallery-desktop` SVG `unsolved-placeholder` is box + "?"
  (Paper / Rule / Ink), matching the draw path.

## Reproduce

```sh
# copy probe/probe_accept_642.gd into game/, then:
HOME=<fresh-home> godot --path game -s res://probe_accept_642.gd -- --debug-seams \
    --session-id=issue-642-accept --build-id=main@2f905b80 \
    --story-ids=PTU-gallery-layout,PTU-gallery-reset,UI-gallery \
    --shot-dir=<run>/screenshots --run-folder=<run>
```
