# Playtest run — issue #557 (graphical acceptance)

- **Issue:** #557 Gallery R2 tiles: metadata copy draws flush to the card border (Reset keeps its 8 px padding) (`type:defect`, `priority:high`)
- **Run id:** `2026-11-04-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-04
- **Build / session id:** `main@6453a43` (carries PR [#561](https://github.com/waigore/simplenono/pull/561) squash `a8811a3`, so `game/` equals the #557 deliverable commit), Godot 4.7.2.stable, session `issue-557-accept`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (`macOS`, Metal Forward+, 390×844 phone frame and 1080×900 desktop frame), fresh `user://` (isolated `HOME`)
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-557-2026-11-04-accept-graphical>

## Scope

The deliverable is the gallery tile body padding, shipped on `main` (PR #561). The judged
protocols, both of which change with `game/presentation/gallery.gd` and `gallery_tile.gd`:

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| `PTU-play-puzzle` S1 / P3 (`J-play-puzzle`, `UI-gallery`, `EX`) | R2's tile chrome at the mockup frames: the copy the #557 report is about |
| `PTU-gallery-reset` S1–S3 / P1–P2 (`J-gallery-reset` US1.1, US1.2) | C2 Reset and `EX.confirm` are drawn inside R2, and #557's fix moves their alignment with the copy above |

Out of scope: `PTD-*`, `PTU-leave-resume`, `PTU-settings`, `PTU-mark-input` — no puzzle,
settings, mark, or persistence code is in the deliverable. On-device R2 baseline (#545)
and R2 scrolling (#539) are separate issues.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-play-puzzle` S1 / P3 portrait | **pass** | 2 columns, 10 px gap, 20 px gutter, tile body padding 8.00 px |
| `PTU-play-puzzle` S1 / P3 landscape | **pass** | 4 columns on 844×390, every column fits, padding held inside 8–12 px |
| R2 desktop frame | **pass** | 1080×900: tile body padding 12.00 px, 32 px gutter, 20 px gap |
| **Defect expected behavior — copy padding** | **pass** | every metadata label keeps the frame's own padding to the card's border (8.00 px at 390 px, 12.00 px at 1080 px) |
| **Defect expected behavior — Reset alignment** | **pass** | the Reset row keeps the same padding the copy above it has, on every drawn tile |
| R2 tile copy containment / picture | **pass** | no label leaves its card; picture square and centered on every drawn tile |
| `PTU-gallery-reset` S1 / P1 (`J-gallery-reset` US1.2) | **pass** | C2 → `EX.confirm` → Cancel: record and tile unchanged |
| `PTU-gallery-reset` S3 / P2 (`J-gallery-reset` US1.1) | **pass** | Confirm clears marks, elapsed, PB, and ever-completed; tile reads Not started, C2 gone |

Capture: **9650 checks `capture: PASS`, 0 `capture: FAIL`**. Final line
`capture: RESULT pass (7 shots, 0 checks failed, graphical)`, exit 0:
[wiki page](https://github.com/waigore/simplenono/wiki/Playtest-issue-557-2026-11-04-accept-graphical)
`logs/capture-graphical.log`.

## Judged states (wiki media, graphical run of this build)

| Screenshot | Judged state |
|------------|--------------|
| `01-gallery-mobile-portrait` | R2 portrait at 390×844 |
| `02-gallery-mobile-landscape` | R2 landscape at 844×390 |
| `03-tile-detail-in-progress-done-best` | the widest phone copy: `#003`, `Done · In progress` + `Best 1:01`, Reset kept |
| `04-tile-detail-desktop-12px` | the desktop frame at 1080×900: 12 px padding on `#003` and every tile |
| `05-reset-confirm` | `EX.confirm` from C2 |
| `06-gallery-after-cancel` | after Cancel: `#003` still Done, best kept |
| `07-gallery-after-confirm` | after Confirm: `#003` Not started, C2 gone |

## Not checked

- On-device confirmation at 360×640 / 640×360 dp — #545 owns the graphical R2 device baseline.
