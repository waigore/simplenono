# Notes — issue #540 acceptance playtest

## What was judged

The R2 gallery tile layout on `main@7e5d825`, against the defect's expected behavior and the
protocols that reach R2:

1. **`PTU-play-puzzle` S1 / P3 portrait** — 390×844 phone frame: two columns, mockup gap and gutter,
   tiles inside the frame.
2. **`PTU-play-puzzle` S1 / P3 landscape** — 844×390: columns and fit.
3. **Every drawn tile, both frames** — label containment, picture squareness and centring, and the
   padding between the copy and the card's border.
4. **`PTU-gallery-reset` S1–S3 / P1–P2** — C2 → `EX.confirm` → Cancel keeps the record; Confirm
   wipes it and the gallery returns to Default.

## How it was driven

`probe/probe_accept_540.gd` boots the shipped `shell.tscn` over a seeded progress document
(`user://progress-accept-540.cfg`, ever-completed + in-progress + PB, written before boot as the
gallery's own tests do). It drives the gallery's real methods (`activate_reset`, the `EX.confirm`
overlay's `cancel`/`confirm`) and reads `DBG.2` through the shell's seams.

Portrait checks the frame's own values; the stage frames are set through `root.size` and the GUI
re-lays out. Two runs: a headless judgement pass and a graphical pass (Metal Forward+, 390×844) whose
frame texture supplies the screenshots. Both finish with `capture: RESULT fail (1206 failures)`.

## Findings

**Pass — spacing.** Portrait reads 2 columns, 10 px gap, 20 px gutter (the mobile mockup's own
values); landscape reads 4 columns on 844×390. Tiles stay inside the frame. This is the reported
"cards too close" symptom, fixed.

**Pass — containment.** No label leaves its card on any drawn tile.

**Pass — thumbnail.** The picture region is square and centered on every drawn tile.

**Pass — reset journey.** Cancel leaves the record byte-identical (`ever_completed`, `in_progress`,
`marks`, `elapsed`, `personal_best`); Confirm clears all five and the tile reads Not started.

**Fail — the status label has no padding inside the card.** On every drawn tile, both frames, the
metadata labels (`10×10 · #003`, `Done · In progress`, `Best 1:01`) are drawn with their text box
ending exactly on the card's right border — 0 px between the copy and the border — while C2 Reset
below them keeps the mockups' 8 px (`gallery_tile.gd`'s `_build_reset_holder()` sets
`margin_left`/`margin_right` 8; the meta `MarginContainer` above it sets only top and bottom).
Both approved mockups pad the whole tile body: `gallery-mobile.html`
`.puzzle-tile .meta { padding: 8px }` and `.puzzle-tile .reset { margin: auto 8px 8px }`;
`gallery-desktop.html` the same at 12 px. The defect asks that each tile's size/id/status text
"stays within its own card without overlapping neighbors" *versus the mockup placeholder* — the copy
touching the border is what the defect calls cramped, and it is visible in `02-gallery-mobile-landscape`.

**Related, non-judged:** the widest mockup state (`Done · In progress` + `Best 9:01`, tile `#062`)
is not elided but has 20 px less room than the mockup's joined `.sub` line leaves it. Recorded here
only; no defect is filed for it.

## Checks on the same tree

`gdformat --check game` clean (95 files), `gdlint game` clean, GUT `res://test` 364/364 passing.

## Device caveat

This run uses a desktop window at the phone frame. The `UIS.T2` type grows with the frame height, so
the padding deficit is proportionally larger on a physical-pixel phone frame (~1080×2340), which is
where the user reported it.

## Reproduce

```sh
cp docs/playtest/evidence/issue-540/probe/probe_accept_540.gd game/
HOME=<fresh-home> godot --headless --path game -s res://probe_accept_540.gd -- --debug-seams \
    --session-id=issue-540-accept --build-id=main@7e5d825 --story-ids=US1.1,US1.2,UI-gallery \
    --shot-dir=<run>/screenshots --run-folder=<run>
HOME=<fresh-home> godot --path game --resolution 390x844 -s res://probe_accept_540.gd -- \
    --debug-seams --session-id=issue-540-accept --build-id=main@7e5d825 \
    --story-ids=US1.1,US1.2,UI-gallery --shot-dir=<run>/screenshots --run-folder=<run>
```
