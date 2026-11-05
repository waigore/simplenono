# Playtest run — issue #640 (graphical acceptance, gallery R2 fling coast)

- **Issue:** #640 Gallery R2: lower scroll friction for longer fling coast (`type:task`, `status:pending-acceptance`, `priority:normal`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** deliverable tree `main@cfed28ea` (PR #656 merge). Sessions `issue-640-accept` ×2 (portrait / landscape), Godot 4.7.2.stable, macOS arm64 (Metal), fresh `user://` per run.
- **Coverage mode:** `full` · graphical, two runs at the `PTU-gallery-layout` test viewports 360×640 and 640×360, seeded `pack-003` for the replay-row stage; plus #640 Experience-intent fling coast
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-640-2026-11-05-accept-graphical>
- **Paths:** this folder’s `notes.md`; wiki page for screenshots and logs

## Scope

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-gallery-layout`](../../../../../specs/playtest/ux/gallery-layout.md) S1–S3 / P1–P6, per point per viewport | AC requires drag-from-tile scroll without open (`P5`); full point list is the regression context after the R2 ScrollContainer subclass and `ScrollDragRelease` fling hand-off |
| `#640` R2 fling coast (Experience intent in `specs/ux/screens/gallery.md`) | AC: after a fling, R2 coasts longer than the engine ScrollContainer default (friction 1000 px/s²) |

Out of scope: `PTD-*` and other `PTU-*` — deliverable is gallery R2 scroll physics only. Puzzle board / marks / non-gallery screens are unchanged in the PR diff.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `#640` R2 is `GalleryR2Scroll`, friction 400 &lt; 1000 (360×640) | **pass** | mid-scroll fling (−900 px/s) travelled 905 px past the engine-default ceiling of 405 px; coast opens no tile |
| `#640` R2 fling coast (640×360) | **pass** | travelled 904 px past engine ceiling 405 |
| `PTU-gallery-layout` P1–P6 (360×640) | **pass** | 2 columns, visible page gutter, labels/thumbs, P5 tap/drag/mouse legs, P6 strip + replay row; 235 C1 drags to last row, 0 mid-drag opens; `pack-199` opens through C1 |
| `PTU-gallery-layout` P1–P6 (640×360) | **pass** | 3 columns; same legs; 163 C1 drags, 0 mid-drag opens; `pack-199` opens through C1 |

Capture: portrait `capture: RESULT pass` (307 PASS checks), landscape `capture: RESULT pass` (232 PASS checks); both exit 0.

GUT (same build): `test_gallery_r2_scroll.gd` 3/3 and `test_touch_input.gd` 10/10 (includes P5 drag-without-open) — all passed.

## Judged states (wiki media, graphical run of this build)

| Screenshot | Judged state |
|------------|--------------|
| `01-portrait-first` | R2 first viewport at 360×640 |
| `02-portrait-scrolled` | final scrolled state after 235 drags |
| `01-landscape-first` | R2 first viewport at 640×360 |
| `02-landscape-scrolled` | final scrolled state after 163 drags |

## Quality evaluators

- **Deterministic** — N/A — deliverable is feel/friction on gallery R2 only; verification already judged it does not move Applies deterministic axes. Acceptance does not run that mode.
- **llm-judge** — N/A — no qualitative rubric axes ([`rubrics/baseline.md`](../../../../../specs/definition/quality/rubrics/baseline.md) is all deterministic).

## Acceptance criteria (issue body)

| Criterion | Evidence |
|-----------|----------|
| R2 after a fling coasts longer than the pre-change default | Probe fling travel ≫ engine ceiling; GUT friction + coast tests; `GalleryR2Scroll.FRICTION = 400` |
| `specs/ux/screens/gallery.md` states locked coast/friction intent | Experience intent paragraph on main@`cfed28ea` |
| Puzzle board, marks, non-gallery screens keep current scroll/feel | PR #656 `game/` diff scoped to gallery presentation + shared `ScrollDragRelease` gallery-only branches |
| Drag-from-tile still scrolls R2 without opening (`PTU-gallery-layout` P5) | Both viewports P5 pass; `test_touch_input` P5 cases green |

## Related PR

- https://github.com/waigore/simplenono/pull/656 (`69a64ce` → merge `cfed28ea`)
