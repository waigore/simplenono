# Playtest run — issue #250 (puzzle pictures pack-070–pack-073, 15×15)

- **Issue:** #250 Puzzle pictures pack-070–pack-073 (15×15) (`type:task`)
- **Run id:** `2026-11-03-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-03
- **Build / session id:** `main@4c0206e` (squash of PR #376); session `issue-250-accept`;
  Godot 4.7.2.stable, graphical on macOS arm64 (Metal), 900×1200
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
  · graphical

## Scope

Deliverable: PR [#376](https://github.com/waigore/simplenono/pull/376) (squash `4c0206e`) — eight
picture files under `game/assets/puzzle-pictures/`, their eight catalog entries,
`assets/manifest.json`, and the rewritten `solution-fills` / `row-clues` / `col-clues` on
`pack-070`–`pack-073` in `game/data/pack.json`.

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
defect #380, owned outside #250. `PTD-pack-finished`, `PTU-leave-resume`, and `PTU-settings`
are not reachable from picture data. No design story changes.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| Pack load | **pass** | 200 entries accepted, 0 rejected |
| `PTU-play-puzzle` S1 / P1 | **pass** | `pack-070` opens via `DBG.3`, ready beat ends, marks allowed |
| `PTD-crosses-and-fills` P1 | **pass** | The solving fill fires `E1` once and reaches the result screen |
| `CMP-shell` R3 | **pass** | Both stored pictures resolve on the result screen |
| `PTU-play-puzzle` P2 | **pass** | Back from result → gallery shows `pack-070` Done, Best 1:00, with its thumbnail |
| `PTU-mark-input` P1 / P5 | **pass** | Tap fills a clear cell; `DBG.2` agrees |
| `PTU-mark-input` P2 / P5 | **pass** | Second tap clears it; `DBG.2` agrees |
| `PTU-mark-input` P3 / P5 | **pass** | Complement on a clear cell crosses it; `DBG.2` agrees |
| `PTU-mark-input` P4 / P5 | **pass** | Drag across 3 clear cells crosses each once; `DBG.2` agrees |
| Unfinished marks | **pass** | Unsolved marks do not complete a puzzle |
| `PTD-crosses-and-fills` P1–P2 on `pack-072` | **pass** | Every non-solution cell crossed first (157 of 225), then its 68 fills: still solves once |
| `PTD-crosses-and-fills` P1–P2 on `pack-073` | **pass** | All 62 fills from the committed row solve once |
| `PTD-solve-and-pb` S1 / P1 | **pass** | `pack-072` and `pack-073` read ever-completed after the solve |

Capture log: **35 `capture: PASS`, 0 `capture: FAIL`, exit 0**, `capture: RESULT pass (9 shots,
0 checks failed)`. Full console, telemetry, and `DBG.2` reads:
[`logs/capture-console.log`](logs/capture-console.log). Final state dump:
[`logs/state-pack-073.json`](logs/state-pack-073.json).

### Falsifiable checks on the picture data

The packs are the shipped rows, so a wrong clue, a wrong `solution-fills` set, or a pixel that
disagrees with the row shows up as "the board will not finish". `pack-072` is the strongest
case: it is played with **every** non-solution cell pre-crossed (157 of 225), so the win can
only land if crosses are non-fills and the fill set is exactly the committed one. Before the
run, independent code re-derived each committed pixel's fill set, clues, uniqueness, and
line-logic solvability from the committed PNGs and matched them to the committed rows
([`tools/expectations.py`](tools/expectations.py), output in [`expect.json`](expect.json)).

| Puzzle | Assigned class (issue) | Subject class (measured) | Filled / 225 (band 56–101) | Unique | Line logic | Row match |
|--------|------------------------|--------------------------|----------------------------|--------|------------|-----------|
| pack-070 | single | single — 1 mass (85), 0 holes | 85 | yes | yes | fills and both clue axes |
| pack-071 | multi / holed | multi — 4 masses (25+25+21+21), 8 holes | 92 | yes | yes | fills and both clue axes |
| pack-072 | multi / holed | multi — 2 masses (35+33), 0 holes | 68 | yes | yes | fills and both clue axes |
| pack-073 | single | single — 1 mass (62), 0 holes | 62 | yes | yes | fills and both clue axes |

Every measured class matches the issue's assignment (index mod 10: 070 single, 071/072
multi and/or holed, 073 single). Every fill count is inside the 56–101 band.

The shared picture bar's derive and judge were also re-run from the committed squares with the
repo's `puzzle_derive.py`: each derived pixel is byte-identical to its committed pixel, and each
judge reports `solutions: 1`, `logic_solved: true`, `matches_pixel: true`
([`logs/derive-judge.log`](logs/derive-judge.log)).

Supporting checks on the deliverable tree — `generate_pack.py --check` reports `pack.json` is
current, `asset_manifest.py --check` reports 0 errors, and all eight catalog entries read
`state: approved`, `coverage: ["V1"]`, `recipe: AK-puzzle-pictures.R1`, `tool_role` `TL.1`
(square) / `TL.2` (pixel) `adr-free`, `review.verdict: Pass`
([`logs/acceptance-checks.log`](logs/acceptance-checks.log),
[`logs/asset-checks.log`](logs/asset-checks.log)).

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`01`](screenshots/01-gallery-fresh.png) | gallery after a full reset, before any solve |
| [`02`](screenshots/02-puzzle-070-open-ready.png) | `pack-070` open, get-set-ready transition |
| [`03`](screenshots/03-puzzle-070-one-fill-from-solve.png) | `pack-070` one fill from solve (84 of 85 placed) |
| [`04`](screenshots/04-result-070-pictures.png) | result screen, morph finished on the stored picture |
| [`05`](screenshots/05-gallery-070-done.png) | gallery after Back: `pack-070` Done, Best 1:00, thumbnail |
| [`06`](screenshots/06-puzzle-071-marks.png) | `pack-071` after fill / clear / complement / drag |
| [`07`](screenshots/07-gallery-071-in-progress.png) | gallery: `pack-071` in progress, not completed |
| [`10`](screenshots/10-puzzle-072-crossed.png) | `pack-072` open with every non-solution cell crossed |
| [`11`](screenshots/11-puzzle-073-last-fill.png) | `pack-073` result screen after its last committed fill solves it |

Judgement text: [`notes.md`](notes.md). Reproduce steps: [`reproduce.md`](reproduce.md).
