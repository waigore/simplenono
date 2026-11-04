# Notes — issue #557 acceptance playtest

## What was judged

The gallery tile body padding on `main@6453a43` (the merged PR #561 deliverable, whose `game/`
tree equals `a8811a3`), against the defect's expected behavior and the protocols that reach R2:

1. **`PTU-play-puzzle` S1 / P3 portrait** — 390×844 phone frame: two columns, the mockups' gap
   and gutter, and the tile body padding at the mobile mockup's 8 px.
2. **`PTU-play-puzzle` S1 / P3 landscape** — 844×390: columns and fit; the frame-held padding
   stays between the mockups' 8 px and 12 px as `tile_padding()` interpolates with the frame
   width.
3. **Desktop mockup frame** — 1080×900: the held 12 px padding, the widest `UIS.T2` chrome, and
   the 32 px / 20 px desktop spacing values, on every drawn tile.
4. **Every drawn tile, both frames** — the two #557 criteria: the metadata copy keeps the frame's
   own padding between the copy and the card's border, and the Reset row keeps the same padding
   the copy above it has. Plus the standing R2 checks: label containment, picture squareness and
   centring.
5. **`PTU-gallery-reset` S1–S3 / P1–P2** — C2 → `EX.confirm` → Cancel keeps the record; Confirm
   wipes it and the gallery returns to Default.

## How it was driven

`probe/probe_accept_557.gd` (adapted from the #540 acceptance probe's committed copy) boots the
shipped `shell.tscn` over a seeded progress document (`user://progress-accept-557.cfg`,
ever-completed + in-progress + PB, written before boot the way the gallery's own tests do). It
drives the gallery's real methods (`activate_reset`, the `EX.confirm` overlay's `cancel` /
`confirm`) and reads `DBG.2` through the shell's seams. The stage frames are set through
`root.size` and the GUI re-lays out. One graphical pass (Metal Forward+) judged every check and
supplied the screenshots. It finishes `capture: RESULT pass (7 shots, 0 checks failed,
graphical)`, exit 0.

## Findings

**Pass — the reported symptom is fixed.** On every drawn tile at both frames, each metadata
label's text box ends at least the frame's padding inside the card — 8.00 px at the 390 px mobile
frame (portrait and the phone-frame detail shot) and 12.00 px at the 1080×900 desktop frame —
where #557's report measured 0.00 px at `main@7e5d825`.

**Pass — Reset matches the copy.** The Reset row is drawn at the same side value as the metadata
block, so the lopsided read (picture inset, copy flush, Reset inset) is gone; both rows now share
the mockups' whole-body padding.

**Pass — the rest of the tile chrome still holds.** Labels stay clipped inside their cards, the
picture is square and centered, and the frame-derived spacing (columns, gap, gutter) still reads
the approved mockups' values, so the fix did not disturb #540's delivered layout.

**Pass — reset journey unchanged.** Cancel leaves the seed record intact; Confirm clears
`ever_completed`, `in_progress`, `marks`, `elapsed`, and `personal_best`, and the tile reads Not
started with C2 unavailable.

## Blockers

None. `game/` at this build equals the `deterministic` record's deliverable commit
[`docs/quality/evidence/issue-540/2026-11-04-verify-4/manifest.md`](https://github.com/waigore/simplenono/blob/main/docs/quality/evidence/issue-540/2026-11-04-verify-4/manifest.md)
(`git diff a8811a3 origin/main -- game/` empty at the run), cited by acceptance rather than
re-run.
