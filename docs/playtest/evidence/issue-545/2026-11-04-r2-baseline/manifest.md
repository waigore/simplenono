# Playtest run — issue #545 (R2 layout baseline, both mobile test viewports)

- **Issue:** #545 Mobile gallery: record a graphical R2 layout baseline at both test viewports for #539 / #540 (`type:task`, `priority:normal`) — **Issue** field also covers the judged targets **#539** and **#540**
- **Run id:** `2026-11-04-r2-baseline`
- **Runner:** `issue-workflow-implement-agent` (parallel id 2), unattended, 2026-11-04
- **Build / session id:** `main@47dae7a`, Godot 4.7.2.stable, display "Apple M5 (Apple9)", macOS arm64, fresh `user://` (isolated `HOME`)
- **Build position note:** `47dae7a` was `main` when the probe ran. Trunk has since moved
  (tile-copy/Reset padding inset landed at `a8811a3` — #557/#540's padding rework — and later
  doc commits); the values in this manifest are the layout of the recorded build, and a
  verify/accept re-run re-derives them from the shipped tree at its own build.
- **Coverage mode:** `critical-only` ([`coverage.md`](../../../../../specs/playtest/coverage.md)); graphical, driven on the shipped shell; the two mobile test viewports from [`specs/view/view.md`](../../../../../specs/view/view.md) (`360×640` and `640×360` dp, first viewport and after a scroll attempt)
- **Wiki page:** https://github.com/waigore/simplenono/wiki/Playtest-issue-545-2026-11-04-r2-baseline

## Scope and reference

The R2 gallery layout on the current `main`, judged against the approved mockup
[`specs/ux/mockups/screens/gallery-mobile.html`](../../../../../specs/ux/mockups/screens/gallery-mobile.html).
`MC.gallery-mobile` was **`approved`** in [`specs/ux/mockups/catalog.md`](../../../../../specs/ux/mockups/catalog.md)
at run time; that row was not changed by this task. **This is a non-accepting baseline**: it
records layout for #539 / #540 to build against and accepts nothing — it must not be counted
as acceptance evidence for another issue.

## Results (per point, per viewport; one pass/fail per point)

| Point | 360×640 (portrait) | 640×360 (landscape) |
|-------|--------------------|---------------------|
| `#540a` card spacing vs the mockup's share | **pass** — 2 columns, gutter 18.5 px (the mockup's 20 share at this frame's 390 rule), gap 10 px; the first row's neighbours sit exactly one gap apart and the next row one gap below | **fail** — the gap is a consistent 16.4 px and the columns follow the wide breakpoint (4), but the layout does not fit the frame: R2's rect is at x=−8, 656 px wide, the first card is drawn clipped off the left edge, the 32 px page margin never appears on screen, and R1's header clips too → **#574** |
| `#540b` per-tile label containment | **pass** — 0 of 600 labels outside their card, 0 truncated | **pass** — 0 of 600 outside, 0 truncated |
| `#540c` thumbnail centring / square | **pass** — every picture square (0 not), spans the card's inner width (0 not), centred (0 not) | **pass** — square / spans inner width / centred (0 not) |
| `#539` R2 scrolls so later tiles are reachable | **pass** — 231 touch swipes, 0 of them opened a tile; offset 27715 of 28190; last tile `#199` (y 350–622 in view 147–622) comes into R2's viewport and opens through C1 | **pass** — 115 touch swipes, 0 opens; offset 13750 of 13934; last row `#196`–`#199` (`#199` at y 65–328 in view 144–328) inside R2's viewport and opens through C1 |

Capture: **42 checks `capture: PASS`, 0 `capture: FAIL`**, final line
`capture: RESULT pass (4 shots, 42 checks, 0 failed)`, exit 0 —
`logs/capture.log` on the run's wiki page.

## New in-game/interface failures found by this run (filed here; not fixed in this task)

- **#574** — the 640×360 frame overshoot recorded on `#540a` above (defect, related to #539 / #540).
- **#573** — the strip of every card below the metadata (the reset row's reserved blank band)
  swallows taps and drags: at 360×640 a tap and a 120 px touch drag starting there both do
  nothing (`observe: 360x640 tile strip below C1 (y=407): tap did nothing; drag-up moved
  nothing`); the approved mockup draws no reset row on a fresh tile and stretches C1 over the
  whole card. The strip lies outside R2's view at the 640×360 fold, so it was not probed there
  (recorded in the capture log).
- **#575** — follow-up task: `PTU-gallery-reset` judges tile status and reset only and cannot
  judge R2 layout, so a layout protocol is proposed for the gallery coverage.

## Waiting

None. The screenshot for every judged state and the logs are on the wiki page for the same build.

## Paths

| Artifact | Path |
|----------|------|
| Probe (run from the repo root, project given by `--path game`) | [`../probe/probe_gallery_r2_baseline.gd`](../probe/probe_gallery_r2_baseline.gd) |
| Capture console (42 PASS, final RESULT) | wiki page, `playtest/issue-545/2026-11-04-r2-baseline/logs/` |
| Screenshots (4 frames) | wiki page, `playtest/issue-545/2026-11-04-r2-baseline/screenshots/` |
| Logs | wiki page, `playtest/issue-545/2026-11-04-r2-baseline/logs/` |

## Reproduce

```sh
run=/tmp/opencode/run545
mkdir -p "$run/home"
HOME="$run/home" godot --path game \
  -s docs/playtest/evidence/issue-545/probe/probe_gallery_r2_baseline.gd -- \
  --build-id=main@47dae7a --shot-dir="$run/shots" --run-folder="$run"
```

The probe sizes the window to each judged frame directly (`root.size` +
`DisplayServer.window_set_size`) because the desktop floor refuses 360 px through
`DisplayServer` alone, seeds the longest copy (`pack-003` `Done · In progress` + `Best 9:01`)
so containment is judged on the worst-case tile, drives the shipped shell's gallery at each
viewport with real touch-drag sequences, and captures `root.get_texture().get_image()` after
the frame that was actually drawn.
