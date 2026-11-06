# Playtest run — issue #693 (graphical acceptance)

- **Issue:** #693 Gallery persisted incomplete-only filter toggle (`type:task`,
  `status:pending-acceptance`, `priority:normal`)
- **Run id:** `2026-11-06-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-06
- **Build / session id:** deliverable tree `main@23e1856`. `game/` there is
  byte-identical to PR #698's head `771474d` (`git diff 771474d 23e1856 -- game/` is
  empty; PRs #697 `ccc85e6` and #698 `5259545` are the deliverable). Session
  `issue-693-accept`, Godot `4.7.2.stable.official.ed1daf0bf`, Linux x86_64, Xvfb,
  fresh `user://`. Frames: 900×1200 (narrow) and 1080×900 (wide).
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-693-2026-11-06-accept-graphical>.
  The headless judgement is the sibling run
  [`../2026-11-06-accept/manifest.md`](../2026-11-06-accept/manifest.md), covering the
  same build.

## Scope

The deliverable adds C5 `Incomplete only` to the gallery as R3's filter row below R1,
a durable `user://gallery-prefs.cfg` preference (`SCH-preferences` F7, ADR-0011), and
S2's empty state.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| Issue AC 2 / 3 / 4 / 5 | The filter, its default, its in-place toggle, and its store are the deliverable |
| `US1.14` (R3 hint, `EX.confirm` disabled chrome) | New UI story row for the filter row |
| [`PTU-gallery-layout`](../../../../../specs/playtest/ux/gallery-layout.md) P1 / P2 | R3 is new chrome; `R1`, `R3`, and the tiles must fit both viewports |
| [`PTU-gallery-reset`](../../../../../specs/playtest/ux/gallery-reset.md) P2 | A reset puzzle is incomplete again and must reappear while the filter is on |

Out of scope: `PTD-*`, `PTU-menu`, `PTU-play-puzzle`, `PTU-leave-resume`,
`PTU-mark-input`, `PTU-play-hints`, `PTU-settings` — the diff touches no rule, mark,
clue, result, menu, input, or settings code, and hint-free earning is explicitly
unchanged.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| AC 2 / default off | **pass** | first launch with no document: C5 off, `Off · shows all 200` |
| AC 2 / durable, survives relaunch | **pass** | C5 on writes `gallery/incomplete-only=true`; a fresh child process reads `stored=true shown=true` |
| AC 3 / off lists all pack puzzles | **pass** | `tiles=200`, R1 `Completed 1 / 200` |
| AC 4 / on hides ever-completed | **pass** | solved `pack-000` hidden, in-progress `pack-001` kept, `199 of 200` |
| AC 5 / toggle updates in place | **pass** | same gallery view before and after both flips; off restores 200 |
| `US1.14` / focus skips hidden tiles | **pass** | no hidden tile in the keyboard-order walk |
| `PTU-gallery-reset` P2 / reset reappears | **pass** | reset with C5 on returns the tile to R2; `tiles=200` |
| `US1.14` / `EX.confirm` blocks C5 | **pass** | C5 `disabled` behind the box, live again after Cancel |
| `PTU-gallery-layout` P1 | **pass** | R1 and R3 inside the frame at 900×1200 and 1080×900 |
| `PTU-gallery-layout` P2 | **pass** | 900×1200 lays 2 columns; 1080×900 lays 4 |

Capture: `capture: RESULT pass (7 shots, 0 checks failed)`, exit 0 —
[`logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-693-2026-11-06-accept-graphical).

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-693/2026-11-06-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-filter-off-all-puzzles.png` | AC 2 / AC 3, `US1.14` | first launch: C5 off in its filter row below R1, 200 tiles |
| `screenshots/02-filter-on-hides-completed.png` | AC 4 / AC 5, `US1.14` | C5 on: `On · hides completed`, the solved tile gone |
| `screenshots/03-completed-hidden-below-fold.png` | AC 4 | C5 on, grid scrolled to the top: the narrowed list |
| `screenshots/04-reset-reappears.png` | `PTU-gallery-reset` P2 | a reset with C5 on returns the tile |
| `screenshots/05-filter-off-again.png` | AC 5 | C5 off again: all 200 back |
| `screenshots/06-wide-filter-row.png` | `PTU-gallery-layout` P1 / P2 | 1080×900: R3 row and four columns inside the frame |
| `screenshots/07-confirm-blocks-c5.png` | `US1.14` | `EX.confirm`: C5 and the chrome draw disabled |

## Paths

| Artifact | Path |
|----------|------|
| Probe (copied to `game/` for the run, removed after) | [`probe_accept_693.gd`](probe_accept_693.gd) |
| Capture console (RESULT pass) | wiki page, `logs/capture.log` |
| `DBG.2` state dump | wiki page, `logs/state-attempt.json` |
| Screenshots (7, graphical run of this build) | wiki page, `screenshots/` |
| Headless judgement of the same build | [`../2026-11-06-accept/manifest.md`](../2026-11-06-accept/manifest.md) |

## Quality evaluator

`deterministic`: reuse — [`docs/quality/evidence/issue-693/2026-11-06-verify-3/manifest.md`](../../../../../docs/quality/evidence/issue-693/2026-11-06-verify-3/manifest.md)
covers `main@5259545`, and `game/` at `5259545` equals `game/` at the deliverable
`771474d` (`git diff 771474d 5259545 -- game/` is empty). No new record written.

`llm-judge`: **N/A** — every axis in
[`specs/definition/quality/rubrics/baseline.md`](../../../../../specs/definition/quality/rubrics/baseline.md)
is `deterministic`, and the domain-axes list is empty.

## Notes

- **Fixtures.** `capture` seeds `pack-000` ever-completed through `CTR-pack` O6
  (`record_solve`) and starts `pack-001` with one marked cell through the player's own
  `Attempt`, so R2 has one tile to hide and one still live for C2's box. A fresh save
  has no progress to filter.
