# Verification rationale — issue #94

Selection arguments are in [selection.md](selection.md); results are in [manifest.md](manifest.md).
This file records why the verdict is `Fail` and what remains on the advisory side.

## Why verification fails

Two material findings, one of them a deterministic-record blocker. Detail follows; the fix
targets are in [`manifest.md`](manifest.md) and [`checks.md`](checks.md).

### 1. `frame-time` is blocked (`no-invariant`)

The target is "≤ 16.7 ms frame time during grid paint **and navigation**". This epic adds the screen
navigation lands on: `Shell._show_gallery()` → `GalleryScreen.refresh()` → `_rebuild()` builds or
re-`setup`s all 200 `GalleryTile` nodes synchronously in that frame. The only frame sample is
`paint`'s grid-paint window, which never draws the gallery; `navigate` starts no `sample_start`, so
`navigate-samples.ndjson` is empty. The outcome can move with this deliverable and nothing sees it.

[`workflow-deterministic-record.md`](../../../../../docs/issues/workflow-deterministic-record.md)
makes a **blocked** row a verification **Fail** — never a Pass with a note. Blocker: give the
navigation window a sample window (`sample_start` before `home`, `sample_stop` after
`result-gallery`, around the gallery refresh) and re-run.

### 2. R2 tile layout drifts from both approved mockups

`MC.gallery-mobile` / `MC.gallery-desktop` give the tile picture a square region
(`aspect-ratio: 1`). The build fixes an 88 px minimum band in a variable-width tile and draws
pictures with `draw_texture_rect(…, false)`, so stored images are stretched. Material, not polish:
it becomes a behaviour gap once #98 ships pictures. #94 returns to implementation and carries the
fix.

## What passed

Unit and harness evidence is in [checks.md](checks.md): O1/O2/O7 and the progress file, `UI-gallery`
R1–R3, C1–C3, S1, the shell gallery route and reset leg, `review-code` Pass, and GUT 218/218.

## Verdict

`Fail` — see the two findings above.
