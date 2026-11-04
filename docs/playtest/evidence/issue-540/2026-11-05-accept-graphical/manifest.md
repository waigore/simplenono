# Playtest run — issue #540 (graphical acceptance, layout)

- **Issue:** #540 Mobile gallery tiles: cramped spacing, overlapping labels, uncentered thumbnails (`type:defect`, `priority:high`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** `main@9a32abc` (origin/main; `git diff ee1d2fd 9a32abc -- game/` is
  empty, so `game/` equals the shipped-tree record
  [`issue-574/2026-11-05-verify/manifest.md`](../../../../quality/evidence/issue-574/2026-11-05-verify/manifest.md)),
  Godot 4.7.2.stable, Metal Forward+ (macOS, Apple M5), sessions `portrait` / `landscape` / `issue-540-accept`, fresh `user://` per run
- **Coverage mode:** `full` · graphical, three runs (360×640 and 640×360 test viewports, plus the mobile mockup frame 390×844 for the reset journey)
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-540-2026-11-05-accept-graphical>

## Scope

The deliverable is the R2 gallery tile layout shipped on `main` (PR #547 + the follow-on
tile-body padding #561, the tile-band restore #579, and the 640×360 frame-fit #580). The
judged protocols, all of which reach `UI-gallery` R2:

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-gallery-layout`](../../../../../specs/playtest/ux/gallery-layout.md) S1–S3 / P1–P6 | The protocol the deliverable was fixed against; judges spacing, containment, thumbnail geometry, scroll reach, and strip routing per point per viewport (360×640, then 640×360) |
| `PTU-play-puzzle` S1 / P3 (`J-play-puzzle`, `UI-gallery`) | R2 tile chrome at the mobile mockup frames (portrait 390×844, landscape 844×390) and the defect's three symptoms |
| `PTU-gallery-reset` S1–S3 / P1–P2 (`J-gallery-reset` US1.1, US1.2) | C2 Reset and `EX.confirm` are drawn inside R2; the tile band below the metadata changed with #579 |

Out of scope: `PTD-*`, `PTU-leave-resume`, `PTU-settings`, `PTU-mark-input` — no puzzle,
settings, mark, or persistence code is in the deliverable. #539 (scroll defect), #545
(device baseline), #550 (harness solve flake), and #573 (dup-symptom defect) stay with
their owners; the #545 baseline is explicitly non-accepting evidence and is not cited.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-gallery-layout` P1 (360×640) | **pass** | margin 18.5 px visible on both sides; every region and row-0 card inside the window |
| `PTU-gallery-layout` P2 (360×640) | **pass** | 2 columns (cards 153 px), gap 10.0 px, gutter 18.5 px, per the frame rule |
| `PTU-gallery-layout` P3 (360×640) | **pass** | 0 of 612 labels outside a card or truncated at the settled scroll |
| `PTU-gallery-layout` P4 (360×640) | **pass** | thumb square (aspect 1.000), full card width, centered |
| `PTU-gallery-layout` P5 (360×640) | **pass** | 229 card drags, no mid-drag open; pack-199 reached and opened through C1 |
| `PTU-gallery-layout` P6 (360×640) | **pass** | metadata-strip tap opens the tile (C1); strip drag scrolls R2; fresh tile has no reset strip (C1 covers the whole card) |
| `PTU-gallery-layout` P1–P6 (640×360) | **pass** | 3 columns × ~179 px, gutter 32 px, gap 16.41 px (the wide rule, `_columns_for_width`), margin visible, 0 containment misses, aspect 1.000, 161 drags with no open, below-fold tile opened, strip tap/drag routed |
| `PTU-play-puzzle` S1 / P3 portrait | **pass** | 2 columns, 10 px gap, 20 px gutter at 390×844; labels and pictures as delivered |
| `PTU-play-puzzle` S1 / P3 landscape | **pass** | columns, spacing inside the mockups' bounds, every column fits the frame |
| `PTU-gallery-reset` S1–S3 / P1–P2 | **pass** | C2 → `EX.confirm` → Cancel: record byte-identical; Confirm: every field cleared, tile reads Not started, C2 unavailable |

Capture: final line of each log — portrait `capture: RESULT pass` (289 PASS checks), landscape
`capture: RESULT pass` (206 PASS checks), reset `capture: RESULT pass (6 shots, 0 checks failed,
graphical)`; all exit 0. Logs on this page: `logs/` (capture-*.log plus the three S5 state dumps,
`state-portrait.json` / `state-landscape.json` / `state-reset.json`).

## Judged states (wiki media, graphical run of this build)

| Screenshot | Judged state |
|------------|--------------|
| `01-portrait-first` | R2 first viewport at 360×640 (2 columns, gutter, gap) |
| `02-portrait-scrolled` | final scrolled state after 229 drags: last row #196–#199 inside the window |
| `01-landscape-first` | R2 first viewport at 640×360 (3 columns, the wide rule's fit) |
| `02-landscape-scrolled` | final scrolled state after 161 drags |
| `01-gallery-mobile-portrait` | mobile mockup frame 390×844, seeded record |
| `02-gallery-mobile-landscape` | 844×390 |
| `03-tile-detail-in-progress-done-best` | the longest copy tile: Done · In progress + Best |
| `04-reset-confirm` | `EX.confirm` drawn over the gallery |
| `05-gallery-after-cancel` | after Cancel: tile unchanged, record byte-identical |
| `06-gallery-after-confirm` | after Confirm: tile Not started, C2 gone |

## Not checked

- On-device confirmation at 360×640 / 640×360 dp — #545 owns the graphical R2 device baseline
  and stays separate.
