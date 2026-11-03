# Playtest run — issue #247 (puzzle pictures pack-058–pack-061, 15×15)

- **Issue:** #247 Puzzle pictures pack-058–pack-061 (15×15) (`type:task`)
- **Run id:** `2026-11-03-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-03
- **Build / session id:** `main@12f2c8f` (squash of PR #368); session `issue-247-accept`;
  Godot 4.7.2.stable, graphical on macOS arm64 (Metal), 900×1200
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
  · graphical

## Scope

Deliverable: PR [#368](https://github.com/waigore/simplenono/pull/368) (squash `12f2c8f`) — eight
picture files under `game/assets/puzzle-pictures/`, their eight catalog entries,
`assets/manifest.json`, and the rewritten `solution-fills` / `row-clues` / `col-clues` on
`pack-058`–`pack-061` in `game/data/pack.json`.

The deliverable adds static pictures and rewrites four pack rows. It changes no runtime code,
but it does change **playable pack data**: what the board fills, which cells are crossed, and
which pictures the result screen reveals. Protocols were selected by that reach:

| Protocol / story | Why it is in scope |
|------------------|--------------------|
| `PTU-play-puzzle` P1–P2 | Gallery → puzzle → result → gallery; the tile reads `Done` after Back |
| `CMP-shell` R3 | Both stored pictures resolve and draw on the result screen |
| `PTD-solve-and-pb` S1 / P1 | First solve on a shipped puzzle sets ever-completed |
| `PTD-crosses-and-fills` P1–P2 | Win lands when the shipped `solution-fills` are filled, with crosses on the rest |
| `PTD-ready-and-marks` P1 | Marks blocked during get-set-ready, allowed after |
| `PTU-mark-input` P1–P5, US1.6/6b/7/8 | Fill, clear, complement, drag on the new 15×15 boards |

Out of scope with reason: `PTU-gallery-reset` S1–S3 exercises the `EX.confirm` reset dialog,
which is `#96` work and untouched by this slice; its first-open blank card is the pre-existing
defect #380, owned outside #247. `PTD-pack-finished`, `PTU-leave-resume`, and `PTU-settings`
are not reachable from picture data. No design story changes.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| Pack load | **pass** | 200 entries accepted, 0 rejected |
| `PTU-play-puzzle` S1 / P1 | **pass** | `pack-058` opens via `DBG.3`, ready beat ends, marks allowed |
| `PTD-crosses-and-fills` P1 | **pass** | The solving fill fires `E1` once and reaches the result screen |
| `CMP-shell` R3 | **pass** | Both stored pictures resolve on the result screen |
| `PTU-play-puzzle` P2 | **pass** | Back from result → gallery shows `pack-058` Done, Best 1:00, with its thumbnail |
| `PTU-mark-input` P1 / P5 | **pass** | Tap fills a clear cell; `DBG.2` agrees |
| `PTU-mark-input` P2 / P5 | **pass** | Second tap clears it; `DBG.2` agrees |
| `PTU-mark-input` P3 / P5 | **pass** | Complement on a clear cell crosses it; `DBG.2` agrees |
| `PTU-mark-input` P4 / P5 | **pass** | Drag across 3 clear cells crosses each once; `DBG.2` agrees |
| Unfinished marks | **pass** | Unsolved marks do not complete a puzzle |
| `PTD-crosses-and-fills` P1–P2 on `pack-060` | **pass** | Every non-solution cell crossed first (168 of 225), then its 57 fills: still solves once |
| `PTD-crosses-and-fills` P1–P2 on `pack-061` | **pass** | All 73 fills from the committed row solve once |
| `PTD-solve-and-pb` S1 / P1 | **pass** | `pack-060` and `pack-061` read ever-completed after the solve |

Capture log: **36 `capture: PASS`, 0 `capture: FAIL`, exit 0**, `capture: RESULT pass (9 shots,
0 checks failed)`. Full console, telemetry, and `DBG.2` reads:
[`logs/capture-console.log`](logs/capture-console.log). Final state dump:
[`logs/state-pack-061.json`](logs/state-pack-061.json).

### Falsifiable checks on the picture data

The packs are the shipped rows, so a wrong clue, a wrong `solution-fills` set, or a pixel that
disagrees with the row shows up as "the board will not finish". `pack-060` is the strongest
case: it is played with **every** non-solution cell pre-crossed (168 of 225), so the win can
only land if crosses are non-fills and the fill set is exactly the committed one. Before the
run, independent code re-derived each committed pixel's fill set, clues, uniqueness, and
line-logic solvability from the committed PNGs and matched them to the committed rows
([`tools/expectations.py`](tools/expectations.py), output in [`expect.json`](expect.json)).

| Puzzle | Subject class (measured) | Filled / 225 (band 56–101) | Unique | Line logic | Row match |
|--------|--------------------------|----------------------------|--------|------------|-----------|
| pack-058 | multi — 2 masses (45 + 44), 0 holes | 89 | yes | yes | fills and both clue axes |
| pack-059 | multi — 2 masses (48 + 22), 0 holes | 70 | yes | yes | fills and both clue axes |
| pack-060 | single — 1 mass (57), 1 hole | 57 | yes | yes | fills and both clue axes |
| pack-061 | multi — 2 masses (45 + 28), 0 holes | 73 | yes | yes | fills and both clue axes |

The shared picture bar's derive and judge were also re-run from the committed squares with the
repo's `puzzle_derive.py`: each derived pixel is byte-identical to its committed pixel, and each
judge reports `solutions: 1`, `logic_solved: true`, `matches_pixel: true`
([`logs/derive-judge.log`](logs/derive-judge.log)).

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`01`](screenshots/01-gallery-fresh.png) | gallery after a full reset, before any solve |
| [`02`](screenshots/02-puzzle-058-open-ready.png) | `pack-058` open, get-set-ready transition |
| [`03`](screenshots/03-puzzle-058-one-fill-from-solve.png) | `pack-058` one fill from solve (88 of 89 placed) |
| [`04`](screenshots/04-result-058-pictures.png) | result screen, morph finished on the stored picture |
| [`05`](screenshots/05-gallery-058-done.png) | gallery after Back: `pack-058` Done, Best 1:00, thumbnail |
| [`06`](screenshots/06-puzzle-059-marks.png) | `pack-059` after fill / clear / complement / drag |
| [`07`](screenshots/07-gallery-059-in-progress.png) | gallery: `pack-059` in progress, not completed |
| [`10`](screenshots/10-puzzle-060-crossed.png) | `pack-060` open with every non-solution cell crossed |
| [`11`](screenshots/11-puzzle-061-last-fill.png) | `pack-061` at its last fill, before the win |

Judgement text: [`notes.md`](notes.md). Reproduce steps: [`reproduce.md`](reproduce.md).
