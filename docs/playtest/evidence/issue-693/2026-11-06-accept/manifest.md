# Playtest run — issue #693 (headless acceptance)

- **Issue:** #693 Gallery persisted incomplete-only filter toggle (`type:task`,
  `status:pending-acceptance`, `priority:normal`)
- **Run id:** `2026-11-06-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-06
- **Build / session id:** deliverable tree `main@23e1856` — `game/` there is
  byte-identical to PR #698's head `771474d` (`git diff 771474d 23e1856 -- game/` is
  empty), the commits PRs #697 `ccc85e6` and #698 `5259545` landed. Session
  `issue-693-accept`, Godot `4.7.2.stable.official.ed1daf0bf`, Linux x86_64, headless,
  fresh `user://` (`~/.local/share/simplenono` cleared before each run).
- **Coverage mode:** `full` · headless (screenshots wait on the graphical re-run —
  [`2026-11-06-accept-graphical`](../2026-11-06-accept-graphical/manifest.md))
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-693-2026-11-06-accept>

## Scope

The deliverable adds C5 `Incomplete only` to the gallery (R3 filter row below R1), a
durable `user://gallery-prefs.cfg` preference (`SCH-preferences` F7, ADR-0011), and
S2's empty state.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| Issue AC 2 / 3 / 4 / 5 | The filter, its default, its in-place toggle, and its durable store are the deliverable |
| [`PTU-gallery-layout`](../../../../../specs/playtest/ux/gallery-layout.md) P1 / P2 | R3 is a new chrome region on the gallery; `R1`, `R3` and the tiles must fit both viewports |
| [`PTU-gallery-reset`](../../../../../specs/playtest/ux/gallery-reset.md) P2, S1/S2 disabled chrome | A reset puzzle becomes incomplete again and must reappear while the filter is on |
| `US1.14` (R3 hint, `EX.confirm` disabled chrome) | New UI story row |

Out of scope: `PTD-*`, `PTU-menu`, `PTU-play-puzzle`, `PTU-leave-resume`,
`PTU-mark-input`, `PTU-play-hints` — no rule, mark, clue, result, menu, input, or
hint-earning code is in the deliverable's diff (hint-free earning is explicitly
unchanged). `PTU-settings` P1 was re-checked only to confirm the new row did not break
the gallery → settings → gallery route; see the graphical manifest.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| AC 2 / default off | **pass** | first launch with no document: `stored=false`, C5 off, `Off · shows all 200` |
| AC 2 / durable, survives relaunch | **pass** | C5 on → `stored=true`; a fresh child process reads `stored=true shown=true` (twice) |
| AC 2 / missing or unreadable → off | **pass** | cold launch with no document reads off; unreadable/non-boolean values are covered by `test_missing_or_unreadable_values_read_as_off` |
| AC 3 / off lists all pack puzzles | **pass** | `tiles=200`, R1 `Completed 1 / 200` |
| AC 4 / on hides ever-completed | **pass** | solved `pack-000` ever-completed: `tiles 200 -> 199`; `pack-001` in progress stays visible |
| AC 5 / toggle updates in place | **pass** | `view=gallery` before and after both flips; off restores 200 |
| `US1.14` / focus skips hidden tiles | **pass** | keyboard-order walk finds no hidden tile; focusables 203 → 202 |
| `PTU-gallery-reset` P2 / reset reappears | **pass** | with C5 on and `pack-000` hidden, `reset_puzzle` → tile back, `tiles=200` |
| `US1.14` / `EX.confirm` blocks C5 | **pass** | box shown for an in-progress tile: C5 `disabled=true`; Cancel releases it |
| Reset B2 / Cancel writes nothing | **pass** | after Cancel the target tile is still not-ever-completed and still shown |
| `PTU-gallery-layout` P1 | **pass** | R1 and R3 inside the frame at 360×640 and 640×360 (`bar_x` 10..350 / 32..608) |
| `PTU-gallery-layout` P2 | **pass** | 360×640 lays 2 columns, 640×360 lays 3 (the mockup's hold-between-frames rule) |
| S2 empty-state copy | **pass** | `All puzzles completed` is the drawn R2 empty label |

Two consecutive runs of the same driver on the same build returned identical results
(18 judged lines each, no failures).

## Paths

| Artifact | Path |
|----------|------|
| Driver (headless; no frames) | [`driver.gd`](driver.gd) |
| Judged detail, harness caveats | [`notes.md`](notes.md) |
| Wiki page with screenshots (graphical run of the same build) | <https://github.com/waigore/simplenono/wiki/Playtest-issue-693-2026-11-06-accept> |
| Graphical run folder | [`../2026-11-06-accept-graphical/manifest.md`](../2026-11-06-accept-graphical/manifest.md) |

**Screenshots:** waiting — this headless run judges from logs and inspection. A
graphical re-run of `main@23e1856` fills the wiki page; see the graphical folder.

## Quality evaluator

`deterministic`: reuse — [`docs/quality/evidence/issue-693/2026-11-06-verify-3/manifest.md`](../../../../../docs/quality/evidence/issue-693/2026-11-06-verify-3/manifest.md)
covers `main@5259545`, and `game/` at `5259545` equals `game/` at the deliverable
`771474d` (`git diff 771474d 5259545 -- game/` is empty). No new record written.

`llm-judge`: **N/A** — every axis in
[`specs/definition/quality/rubrics/baseline.md`](../../../../../specs/definition/quality/rubrics/baseline.md)
is `deterministic`, and the domain-axes list is empty.
