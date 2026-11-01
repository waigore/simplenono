# Playtest run — issue #93 (graphical acceptance)

- **Issue:** #93 Core solve loop vertical (`type:epic`, Wave 1 — Playable core solve loop)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@94e6c55`, Godot 4.7.2.stable, session `issue-93-capture`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (Metal, 900×1200)
- **Levels:** Design (`PTD-ready-and-marks`, `PTD-crosses-and-fills`, `PTD-solve-and-pb`) and UX (`PTU-play-puzzle`)

## Scope

The epic owns the stories `L-solve` (#109), `E-cell` (#106), `E-clue` (#107), `GS` (#108),
`E-puzzle` (#105), `IN` (#111), `J-play-puzzle` (#112, open leg) and `UI-puzzle` (#110)
([`story-rows.md`](../../../../../specs/playtest/story-rows.md)). Intersecting that set with
the protocol `Cites` rows leaves four protocols:

| Protocol | Cites | Why it is in scope |
|----------|-------|--------------------|
| `PTD-ready-and-marks` | `L-solve`, `E-cell`, `E-clue`, `GS`, `E-puzzle` | every cited story is this epic's |
| `PTD-crosses-and-fills` | `E-cell`, `GS`, `E-clue`, `L-solve`, (`END`) | `END` is out of scope; the rest are the epic's |
| `PTD-solve-and-pb` | `L-solve`, `GS`, (`END`, `PRG`) | `END`/`PRG` are #97; the epic's part is solved-state + elapsed |
| `PTU-play-puzzle` | `J-play-puzzle`, `UI-puzzle`, (`UI-gallery`, `UI-result`, `NAV`, `ACT-player`) | the whole journey now runs, so the full Y1 cycle is judged |

Since the verification run at `dcd9a24`, only #199/#202/#208 (gallery, settings and result
screens) touched the tree. They complete the journey the epic's open leg feeds, so this run
judges the full `PTU-play-puzzle` cycle instead of deferring its result legs.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-ready-and-marks` S1 — no mark during get-set-ready | **pass** | two viewport taps on clear cells left the grid unchanged |
| `PTD-ready-and-marks` P1 — clear → fill → clear → cross after Ready | **pass** | Fill, Clear and Cross tools each write through the cell |
| `PTD-ready-and-marks` P2 — empty-clue auto-cross | **pass** | rows 0 and 9 have empty clues; both were fully auto-crossed on Ready |
| `PTD-ready-and-marks` P3 — wrong fill stays playable; pause freezes elapsed and blocks marks | **pass** | contradicting fill cues `GS.row-error`, no fail state; settings pause froze elapsed, the input layer refused the stroke, Back resumed through O5 |
| `PTD-crosses-and-fills` P1 — fills + crosses solve | **pass** | a wholly crossed non-solution board plus correct fills reached the result screen |
| `PTD-crosses-and-fills` P2 — crosses are not fills | **pass** | the fully crossed, one-fill-short board still read not solved |
| `PTD-solve-and-pb` P1 — first solve | **pass** | ever-completed true, attempt not in progress, marks/elapsed cleared, PB = the run's 1:30 |
| `PTD-solve-and-pb` P2 — longer replay keeps the PB | **pass** | the 2:25 replay kept PB 1:30; a later replay longer than the improved PB kept it too |
| `PTD-solve-and-pb` P3 — shorter replay improves the PB | **pass** | a 0:01 replay replaced PB 1:30; marks cleared again |
| `PTU-play-puzzle` P1 — gallery → puzzle → result → gallery | **pass** | real get-set-ready wait, solve reached `UI-result`, morph, C1 Back returned to the gallery |
| `PTU-play-puzzle` P2 — the gallery shows the puzzle done | **pass** | tile reads `Done` with `Best 0:01` after the return |
| `PTU-leave-resume` | not in scope | no story row is this epic's (#96 owns the journey) |
| `PTU-gallery-reset`, `PTU-settings` | not in scope | `UI-gallery` / `UI-settings` are not this epic's stories |
| `PTD-pack-finished` | not in scope | cites `END`/`PRG` only (#97) |

Every required protocol passed. No game or interface fail was observed.

## Screenshots

All images are from this graphical run on `main@94e6c55`.

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-s1-gallery-start.png) | `PTU-play-puzzle` S1: the app starts on `UI-gallery`, `Completed 0 / 200` |
| [`01`](screenshots/01-s2-get-set-ready-blocked.png) | `PTD-ready-and-marks` S1: get-set-ready, marks blocked |
| [`02`](screenshots/02-s3-s1-ready-empty-clues-crossed.png) | S2/P2: Ready, the empty-clue rows 0 and 9 auto-crossed |
| [`03`](screenshots/03-s4-tap-fill.png) | S2/P1: a tap fills (1, 4); clue `1` dims as satisfied |
| [`04`](screenshots/04-s5-tap-clear.png) | S2/P1: the Clear tool clears the same cell |
| [`05`](screenshots/05-s6-tool-cross-and-tap.png) | S2/P1: the Cross tool crosses (2, 3) |
| [`06`](screenshots/06-s7-contradiction-cue.png) | S3/P3: a contradicting fill; row 0's `4` shows the error cue, the attempt stays playable |
| [`07`](screenshots/07-s8-paused-marks-blocked.png) | S4/P3: the paused session (settings shown; elapsed frozen) |
| [`08`](screenshots/08-s9-resumed-after-settings-back.png) | S4/P3: Back resumed; marks accepted and elapsed ticking again |
| [`10`](screenshots/10-crosses-filled-and-crossed.png) | `PTD-crosses-and-fills` S1: correct fills plus a fully crossed remainder, one fill short |
| [`11`](screenshots/11-solve-result-morph-pixel.png) | `PTD-crosses-and-fills` S2/P1: the solve's carried board in the result's first morph stage |
| [`12`](screenshots/12-solve-result-stage-default.png) | S3: the morph reaches Default; C1 `Back to gallery` is drawn |
| [`20`](screenshots/20-replay-in-progress-start.png) | `PTD-solve-and-pb` S2: the longer replay (`2:25`), one fill short |
| [`21`](screenshots/21-replay-longer-result.png) | S2/P2: the longer replay solved; the PB stays 1:30 (`Best` on the tile) |
| [`22`](screenshots/22-replay-gallery-leaves-pb.png) | P2: the gallery tile reads `Done` / `Best 1:30` |
| [`23`](screenshots/23-replay-shorter-result.png) | S3/P3: the shorter replay solved and replaced the PB |
| [`24`](screenshots/24-play-puzzle-gallery-done-tile.png) | `PTU-play-puzzle` S4/P2: back on the gallery; the solved tile reads `Done` / `Best 0:01` |

## Paths

| Artifact | Path |
|----------|------|
| Notes, reproduce steps | [`notes.md`](notes.md) |
| Probe (removed from `game/` after the run) | [`probe/probe_capture_93.gd`](probe/probe_capture_93.gd) |
| Capture console (133 passing checks, telemetry) | [`logs/capture-console.log`](logs/capture-console.log) |
| State dumps (`DBG.2` / `SIT.3`) | [`logs/state-pack-000.json`](logs/state-pack-000.json), [`logs/state-pack-002.json`](logs/state-pack-002.json) |
| GUT suite at `94e6c55`: 19 scripts, 215/215, 29 956 asserts, exit 0 | [`logs/gut-suite.log`](logs/gut-suite.log) |

## Reproduce

```sh
godot --path game -s res://probe_capture_93.gd -- --debug-seams \
  --session-id=issue-93-capture --build-id=main@94e6c55 \
  --story-ids=L-solve,E-cell,E-clue,GS,E-puzzle,J-play-puzzle,UI-puzzle \
  --shot-dir=<run folder>/screenshots --dump-dir=<run folder>
```

Copy [`probe/probe_capture_93.gd`](probe/probe_capture_93.gd) into `game/` first; remove it
afterward. Exit code 0 means every judged state was reached.

## Quality evaluator

`deterministic`: cited from verification, not re-run here — see the acceptance comment.
`llm-judge`: N/A — no domain axes are declared ([`rubrics.md`](../../../../../specs/definition/quality/rubrics.md)).
