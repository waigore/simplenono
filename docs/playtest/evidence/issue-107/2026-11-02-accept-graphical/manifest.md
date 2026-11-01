# Playtest run — issue #107 (graphical)

- **Issue:** #107 Clue line derivation (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@aff969b`, Godot 4.7.2.stable; session `issue-107-capture`
- **Coverage mode:** `full` · **Run type:** graphical (Metal 4.0, 900×1200, viewport images)
- **Level:** Design (`E-clue`)

## Scope

The deliverable is PR [#121](https://github.com/waigore/simplenono/pull/121) (`e59d55e`, squash
`ed9e33b`). Since the last judged build (`22c88c2`) its only change is `c864c6b` (#127), a
`gdlint` reflow of `game/play/clue_lines.gd` and `game/test/test_clue_lines.gd` —
whitespace and line wrapping. Earlier holds waited on a build that drew nothing; `#110`
(`2601fee`) draws the board and clue bars, `#112` (`f05441c`) routes the shell to it, and
`#132` (`dd0948b`) supplies the empty-line auto-cross.

Protocols: `PTD-ready-and-marks` and `PTD-crosses-and-fills` (both cite `E-clue`). Only
`E-clue` P1–P3 and `PTD-ready-and-marks` P2 are decided by this deliverable.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `E-clue` P1 orientation | **pass** | row and column lines are separate model lines drawn in separate bars |
| `E-clue` P2 line index | **pass** | indices `0…size−1` per orientation (fixture row 3 `[]`, column 3 `[3]`) |
| `E-clue` P3 run lengths; empty = all-empty | **pass** | verbatim F3/F4 lists; an empty list is a zero-run line in its own slot, drawn `·` |
| `PTD-ready-and-marks` P2 empty-clue auto-cross | **pass** | pack-000: exactly rows 0, 9 crossed (20 cells); pack-001: exactly columns 0, 1, 8, 9 (40 cells); attempt `in_progress`, elapsed `0:00` |
| `E-clue` S1/S2/I2/I4 | out of scope | `CMP-rules` R2/R3, #108 |
| `PTD-ready-and-marks` S1/S3/S4, P1/P3 | out of scope | marks and pause; judged by #156's graphical run |
| `PTD-crosses-and-fills` P1–P2 | out of scope | `GS.is-solved` (#108) and the result screen (#95) |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-fresh-ready-clue-lines.png) | pack-000 fresh get-set-ready: 10 + 10 clue lines, rows 0 and 9 show `·` |
| [`01`](screenshots/01-ready-empty-rows-autocrossed.png) | after Ready: exactly the two empty rows crossed, all other cells clear |
| [`02`](screenshots/02-fresh-ready-empty-columns.png) | pack-001 fresh: `·` on columns 0, 1, 8, 9 |
| [`03`](screenshots/03-ready-empty-columns-autocrossed.png) | after Ready: exactly those four columns crossed |

`00`/`02` are dimmed by the Ready panel — the board is inert during get-set-ready.

## Paths

See [`artifacts.md`](artifacts.md) for every artifact and its state.

## Quality evaluator

No Applies axis can move: every baseline axis is `deterministic` and scored at
integration/smoke level by `verification/invariants.md` I1–I11, and this deliverable is a pure
model with no screen, timing, persistence, or telemetry output. `llm-judge` is N/A —
[`rubrics.md`](../../../../../specs/definition/quality/rubrics.md) declares no domain axes.

## Reproduce

```sh
cp docs/playtest/evidence/issue-107/2026-11-02-accept-graphical/probe/probe_capture_107.gd game/
godot --path game -s res://probe_capture_107.gd -- --debug-seams \
  --session-id=issue-107-capture --story-ids=E-clue,PTD-ready-and-marks \
  --shot-dir="$(pwd)/docs/playtest/evidence/issue-107/2026-11-02-accept-graphical/screenshots"
rm game/probe_capture_107.gd
```
