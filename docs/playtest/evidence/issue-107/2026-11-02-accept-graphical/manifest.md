# Playtest run — issue #107 (graphical)

- **Issue:** #107 Clue line derivation (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@aff969b`, Godot 4.7.2.stable; session `issue-107-capture`
- **Coverage mode:** `full` · **Run type:** graphical (Metal 4.0, 900×1200, viewport images)
- **Level:** Design (`E-clue`)

## Scope

The deliverable is PR [#121](https://github.com/waigore/simplenono/pull/121) (`e59d55e`, squash
`ed9e33b`). Compared with the last judged build (`22c88c2`), the only change under the deliverable
is `c864c6b` (#127), which reformats `game/play/clue_lines.gd` and
`game/test/test_clue_lines.gd` for `gdlint`; the diff is whitespace and line wrapping only. The
five earlier holds waited on a build that could draw anything; `#110` (`2601fee`) now draws the
board and clue bars, `#112` (`f05441c`) routes the shell to it, and `#132` (`dd0948b`) supplies
the empty-line auto-cross. This run therefore judges the clue layer on a graphical build and
supplies the screenshots every earlier run was waiting for.

Protocols: `PTD-ready-and-marks` (cites `E-clue`) and `PTD-crosses-and-fills` (cites `E-clue`).
Only `E-clue` P1–P3 and `PTD-ready-and-marks` P2 are decided by this deliverable.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `E-clue` P1 orientation | **pass** | 15 row + 15 column lines, distinguished by orientation in the mapper and on the board |
| `E-clue` P2 line index | **pass** | indices `0…size−1` per orientation; row 3 and column 3 differ in content (fixture) |
| `E-clue` P3 run lengths; empty = all-empty | **pass** | verbatim F3/F4 lists; empty list is a zero-run line in its own slot, rendered `·` |
| `PTD-ready-and-marks` P2 empty-clue auto-cross | **pass** | pack-000: exactly rows 0 and 9 crossed (20 cells), attempt `in_progress`, elapsed `0:00`; pack-001: exactly columns 0, 1, 8, 9 (40 cells) |
| `E-clue` S1 / S2 / I2 / I4 (line status, satisfied dim, line error) | out of scope | `CMP-rules` R2/R3, #108; not part of this task's deliverable |
| `PTD-ready-and-marks` S1/S3/S4 and P1/P3 | out of scope | marks and pause; judged by #156's graphical run, not this mapper |
| `PTD-crosses-and-fills` P1–P2 | out of scope | `GS.is-solved` is #108; `PTD-solve-and-pb` and the result screen (#95) are not on this build |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-fresh-ready-clue-lines.png) | pack-000 fresh get-set-ready: 10 row + 10 column clue lines, rows 0 and 9 show `·` |
| [`01`](screenshots/01-ready-empty-rows-autocrossed.png) | after Ready: exactly the two empty rows auto-crossed, every other cell clear |
| [`02`](screenshots/02-fresh-ready-empty-columns.png) | pack-001 fresh: empty-run glyph on columns 0, 1, 8, 9 (column orientation) |
| [`03`](screenshots/03-ready-empty-columns-autocrossed.png) | after Ready: exactly those four empty columns auto-crossed |

Screenshots `00`/`02` are dimmed by the Ready panel: the board is inert during get-set-ready.
That is the delivered state; the clue bars remain readable.

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes, criteria, falsification | [`notes.md`](notes.md), [`criteria.md`](criteria.md), [`falsification.md`](falsification.md) | present |
| Capture probe, run once and removed from `game/` | [`probe/probe_capture_107.gd`](probe/probe_capture_107.gd) | present |
| Capture console (`TEL.*`, every `capture: PASS`) | [`logs/capture-console.log`](logs/capture-console.log) | present, exit 0 |
| Shipped suite | [`logs/gut-suite.log`](logs/gut-suite.log) | 11 scripts, 139/139, 29 204 asserts, exit 0 |
| Fixture independence check | [`logs/fixture-check.log`](logs/fixture-check.log) | runs recomputed from F5 equal F3/F4; expected literals equal the fixture |
| Falsification — columns read from `row_clues` | [`logs/falsify-columns-from-rows.log`](logs/falsify-columns-from-rows.log) | 13 failing, exit 1 |
| Falsification — short list padded instead of erroring | [`logs/falsify-padded-lists.log`](logs/falsify-padded-lists.log) | 3 failing, exit 1 |

Logs are the native runs stripped of ANSI; every test line and exit status is kept.

## Quality evaluator

No Applies axis can move. Every baseline axis in
[`baseline.md`](../../../../../specs/definition/quality/rubrics/baseline.md) is `deterministic` and scored
at integration/smoke level by `specs/technical/verification/invariants.md` I1–I11; this
deliverable is a pure model with no screen, timing, persistence, or telemetry output. No
`deterministic` record exists for this commit, which is consistent with that. `llm-judge` is N/A:
[`rubrics.md`](../../../../../specs/definition/quality/rubrics.md) declares no domain axes.

## Reproduce

See [`notes.md`](notes.md#reproduce).
