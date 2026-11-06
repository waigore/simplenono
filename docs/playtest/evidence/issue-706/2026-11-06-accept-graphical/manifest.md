# Playtest run — issue #706 (graphical acceptance)

- **Issue:** #706 Open board: draw major grid lines every 5 cells in PAL.C7 Major
  (`type:task`, `status:pending-acceptance`, `priority:normal`)
- **Run id:** `2026-11-06-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-06
- **Build / session id:** `main@5bf6d88` (the deliverable `007d70c` plus the
  evidence-only PR #710; `git diff 007d70c 5bf6d88 -- game/` is empty). Session
  `issue-706-accept`, Godot `4.7.2.stable.official.ed1daf0bf`, Linux x86_64, Xvfb,
  fresh `user://` (`XDG_DATA_HOME` in a temp dir). Frames: 1280×800 desktop,
  360×640 mobile portrait, 640×360 mobile landscape.
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-706-2026-11-06-accept-graphical>

## Scope

The deliverable draws `PAL.C7` Major on every 5-cell boundary of the open board
(`SRF.O2`, `FRM.D1`, `PAL.K6`). It changes the board's appearance, so the protocol
that covers `UI-puzzle` is in scope.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| Issue AC 1 / 2 / 3 | The majors, the palette constant, and the unchanged geometry are the deliverable |
| [`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md) P1 / P2 | The board is `UI-puzzle`; the change must not break gallery → puzzle → result → gallery or ever-completed |
| [`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md) P3 | R2 framing at 20×20 in both orientations, with the new lines drawn |

Out of scope: `PTD-*`, `PTU-menu`, `PTU-gallery-*`, `PTU-leave-resume`,
`PTU-mark-input`, `PTU-play-hints`, `PTU-settings` — the diff touches only the
board's edge drawing and its test.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| AC 1 / 10×10 desktop | **pass** | boundary 5 Major, every other boundary Rule, outer edge Rule |
| AC 1 / 15×15 desktop | **pass** | boundaries 5 and 10 Major, 15 Rule |
| AC 1 / 20×20 desktop | **pass** | boundaries 5, 10, 15 Major |
| AC 1 / 10×10 mobile portrait | **pass** | boundary 5 Major at the mobile cell side |
| AC 1 / 20×20 mobile portrait | **pass** | boundaries 5, 10, 15 Major |
| AC 1 / 20×20 mobile landscape | **pass** | boundaries 5, 10, 15 Major |
| AC 2 / production draw path | **pass** | `edge_color` returns `PresentationPalette.MAJOR`; no literal hex in the draw path |
| AC 3 / geometry | **pass** | cell side, frame, clue bars, and tap areas unchanged; the line sits on the boundary |
| `PTU-play-puzzle` P1 | **pass** | gallery → puzzle → result → gallery completes |
| `PTU-play-puzzle` P2 | **pass** | the solved puzzle reads `Done` after Back |
| `PTU-play-puzzle` P3 | **pass** | 20×20 board inside the portrait and landscape frames |

Capture: `capture: RESULT pass (8 shots, 0 checks failed)`, exit 0 —
[`logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-706-2026-11-06-accept-graphical).

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-706/2026-11-06-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-10x10-desktop.png` | AC 1, AC 2, AC 3 | 10×10 open board: one darker line at 5 on each axis |
| `screenshots/02-20x20-desktop.png` | AC 1, AC 2, AC 3 | 20×20 open board: darker lines at 5, 10, 15 |
| `screenshots/03-15x15-desktop.png` | AC 1 | 15×15 open board: darker lines at 5 and 10, not 15 |
| `screenshots/04-10x10-mobile-portrait.png` | AC 1, P3 | 10×10 at 360×640 |
| `screenshots/05-20x20-mobile-portrait.png` | AC 1, P3 | 20×20 at 360×640, one framing |
| `screenshots/06-20x20-mobile-landscape.png` | AC 1, P3 | 20×20 at 640×360, one framing |
| `screenshots/07-result.png` | P1 | the result screen after the last fill |
| `screenshots/08-gallery-ever-completed.png` | P2 | the solved puzzle reads `Done` |

The rendered frames carry the exact swatches: `#B0BBC3` (Major) and `#C5D0D6`
(Rule) are both present in each desktop capture (790 / 10 966 px on 10×10,
3 420 / 24 282 px on 20×20, 2 250 / 19 485 px on 15×15).

## Paths

| Artifact | Path |
|----------|------|
| Probe (copied to `game/` for the run, removed after) | [`probe_accept_706.gd`](probe_accept_706.gd) |
| Capture console (RESULT pass) | wiki page, `logs/capture.log` |
| `DBG.2` state dump | wiki page, `logs/state-pack-000.json` |
| Screenshots (8, graphical run of this build) | wiki page, `screenshots/` |
| Notes | [`notes.md`](notes.md) |

## Quality evaluator

`deterministic`: reuse — [`docs/quality/evidence/issue-706/2026-11-06-verify-1/manifest.md`](../../../../../docs/quality/evidence/issue-706/2026-11-06-verify-1/manifest.md)
covers `main@007d70c`, and `game/` at `007d70c` equals `game/` at this build
`5bf6d88` (`git diff 007d70c 5bf6d88 -- game/` is empty). No new record written.

`llm-judge`: **N/A** — every axis in
[`specs/definition/quality/rubrics/baseline.md`](../../../../../specs/definition/quality/rubrics/baseline.md)
is `deterministic`, and the domain-axes list is empty.

## Notes

- **Fresh save.** The first attempt reused the host's `~/.local/share/simplenono`
  progress, which already had a stray fill on `pack-000`; the solve leg then could
  not complete. The recorded run uses a fresh `XDG_DATA_HOME`, so the attempt starts
  clean. The board checks were unaffected.
- **Mobile framing.** The host is a desktop build, so the probe sets
  `PuzzleBoard.PLATFORM_MOBILE` to exercise the mobile cell-size rule at the
  360×640 and 640×360 frames. The unit test pins the same `ACHIEVED_CELL` values.
- **No defect.** Every required protocol passed; the screenshots are on the wiki
  page for this build.
