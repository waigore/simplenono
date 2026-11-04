# Playtest run — issue #540 (graphical acceptance)

- **Issue:** #540 Mobile gallery tiles: cramped spacing, overlapping labels, uncentered thumbnails (`type:defect`, `priority:high`)
- **Run id:** `2026-11-04-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-04
- **Build / session id:** `main@7e5d825` (carries PR [#547](https://github.com/waigore/simplenono/pull/547) squash `3762da9`, #549 `0f626cd`, #551 `26df61e`), Godot 4.7.2.stable, session `issue-540-accept`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (`macOS`, Metal Forward+, 390×844 phone frame), fresh `user://` (isolated `HOME`)
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-540-2026-11-04-accept-graphical>

## Scope

The deliverable is the R2 gallery tile layout, shipped on `main`. The judged protocols, both of
which change with `game/presentation/gallery.gd`, `gallery_tile.gd`, and `gallery.tscn`:

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| `PTU-play-puzzle` S1 / P3 (`J-play-puzzle`, `UI-gallery`, `EX`) | R2 on a phone frame in portrait and landscape: the region the defect reports |
| `PTU-gallery-reset` S1–S3 / P1–P2 (`J-gallery-reset` US1.1, US1.2) | C2 Reset and `EX.confirm` are drawn inside R2; its tile reads the same records |

Out of scope: `PTD-*`, `PTU-leave-resume`, `PTU-settings`, `PTU-mark-input` — no puzzle, settings,
mark, or persistence code is in the deliverable. R2 scrolling (#539) and the harness `solve` flake
(#550) are separate issues.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-play-puzzle` S1 / P3 portrait | **pass** | 2 columns, 10 px gap, 20 px gutter, tiles inside the frame |
| `PTU-play-puzzle` S1 / P3 landscape | **pass** | 4 columns on 844×390, every column fits |
| R2 tile copy containment | **pass** | no label reaches its card's border or a neighbour, on every drawn tile |
| R2 tile picture | **pass** | square and centered in its region on every drawn tile |
| `PTU-gallery-reset` S1 / P1 (`J-gallery-reset` US1.2) | **pass** | C2 → `EX.confirm` → Cancel: record and tile unchanged |
| `PTU-gallery-reset` S3 / P2 (`J-gallery-reset` US1.1) | **pass** | Confirm clears marks, elapsed, PB, and ever-completed; tile reads Not started, C2 gone |
| **Defect expected behavior — label status text** | **fail** | the status label is drawn flush against the tile's right border (0 px), not at the mockups' 8 px |

Capture: **5435 checks `capture: PASS` and 1206 `capture: FAIL`** (402 per drawn metadata label
× 3 passes; the same failures repeat at the run level). Final line `capture: RESULT fail` in both
logs, exit 1 on each: [wiki page](https://github.com/waigore/simplenono/wiki/Playtest-issue-540-2026-11-04-accept-graphical)
`logs/capture-headless.log` and `logs/capture-graphical.log`.

## Judged states (wiki media, graphical run of this build)

| Screenshot | Judged state |
|------------|--------------|
| `01-gallery-mobile-portrait` | R2 portrait at 390×844: two columns, `#003` reads `Done · In progress` / `Best 1:01` |
| `02-gallery-mobile-landscape` | R2 landscape at 844×390: four columns |
| `03-tile-detail-in-progress-done-best` | the widest copy: `#062`, `Done · In progress` + `Best 9:01` |
| `04-reset-confirm` | `EX.confirm` from C2 |
| `05-gallery-after-cancel` | after Cancel: `#003` still Done, best kept |
| `06-gallery-after-confirm` | after Confirm: `#003` Not started, C2 gone |

## Not checked

- On-device confirmation at 360×640 / 640×360 dp — #545 owns the graphical R2 device baseline.
