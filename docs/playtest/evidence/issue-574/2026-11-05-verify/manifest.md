# Playtest record — issue #574 layout verification

- **Issue:** #574 Gallery at 640×360: the wide-frame layout exceeds the window (`type:defect`, `status:pending-verification`)
- **Protocol:** [`PTU-gallery-layout`](../../../../../specs/playtest/ux/gallery-layout.md) — judged per point per viewport
- **Build / build id:** branch `defect/574-gallery-fits-landscape-frame` at `ee1d2fd` (PR #580 head), session
  `issue-574-verify`, build `4.7.2-stable (official)`
- **Coverage mode:** graphical headless-off probe (`probe_layout_574.gd` under `probe/`): real shell, shipped pack,
  shipped `DBG` seams, real pointer and touch input at the two test viewports in [`specs/view/view.md`](../../../../../specs/view/view.md)
- **Reporter:** `issue-workflow-verify-agent` (parallel id 1), 2026-11-05, Godot 4.7.2, macOS (darwin) arm64 host
- **Paths:**
  - Wiki page with media: https://github.com/waigore/simplenono/wiki/Playtest-issue-574-2026-11-05-verify
  - Notes: [`notes.md`](notes.md)

## Results

Judged per point and viewport; every cell cites the probe's pass lines in the wiki page's capture logs.

| Point | 360×640 portrait | 640×360 landscape |
|-------|------------------|-------------------|
| P1 frame fit + page margin (`F1`) | pass — `Margin` at 18.5 px per side, cards 18..334 inside the frame, chrome inside | pass — `Margin` at 32 px per side, cards 32..600 inside the frame, header and Settings inside (the recorded defect's `x = −8`, `656 px` overflow does not reproduce) |
| P2 columns follow the mockup's share (`F2`) | pass — 2 columns at 153 px, gap 10, page-margin-relative | pass — 3 columns at ~179 px (the count that fits beside the 32 px margins; the wide minimum of ~712 px steps down), gap 16.41 |
| P3 labels inside their cards (`F3`) | pass — `10×10 · #00n`, `Not started` contained | pass — same on scrolled rows |
| P4 thumbnails square, full-width, centred (`F4`) | pass — thumb = card width 153, drawn square centred (mockup `.open` is full-bleed; only `.meta` takes the padding) | pass — thumb = card width 179 |
| P5 drag scrolls R2; reached below-fold tile opens through C1; no drag opens (`F5`) | pass — 229 card drags reach the last row (pack-199 fully in frame at y 386), tap opens it, no drag raised a tile | pass — 161 card drags reach the last row (pack-199 in frame at y 113), tap opens it |
| P6 metadata-strip tap reaches C1 (C2 when reset is allowed); strip drag scrolls; no blank strip on a fresh card (`F6`) | pass — pack-001 strip tap opens C1, strip drag scrolls R2, C1 spans the whole fresh card | pass — pack-002 strip tap opens C1, strip drag scrolls R2, C1 spans the whole fresh card |

Screenshots — one first-viewport frame and one final scrolled frame per viewport (protocol minimum four frames):

| Viewport | First | Final scrolled |
|----------|-------|----------------|
| 640×360 landscape | `01-landscape-first.png` | `02-landscape-scrolled.png` |
| 360×640 portrait | `01-portrait-first.png` | `02-portrait-scrolled.png` |
