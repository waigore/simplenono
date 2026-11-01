# Deliverables — issue #107

From [criteria.md](criteria.md).

## Deliverables

| Item | Verdict | Evidence |
|------|---------|----------|
| Clue-line view model (`ClueLine`: orientation, index, run lengths, `is_empty`) | **pass** | `game/play/clue_line.gd` |
| Mapper (`ClueLines.from_definition`) | **pass** | `game/play/clue_lines.gd`; probe calls it against the shipped pack-000/pack-001 definitions |
| Outcome type (`ClueLinesResult`, lines or one mapping error) | **pass** | `game/play/clue_lines_result.gd`; error state yields no lines |
| GUT tests | **pass** | `game/test/test_clue_lines.gd`, 17 tests, green in the full suite |
| Fixture | **pass** | `game/test/fixtures/teapot.json`, identical to `pocs/image-nonogram-pipeline/out/teapot/puzzle.json` on `size`/`row_clues`/`col_clues` |
| No new component ID | **pass** | only a clarifying sentence in `CMP-attempt` R2; no spec element added, `CMP-rules` R4 holds |

## Out-of-scope confirmations

- No line status, line error, Satisfied dim, or auto-cross in the delivered files; those are
  `CMP-rules` R2/R3 (#108) and the open-ready edge (#132). The probe's crossed cells are #132's
  output, used only to judge `PTD-ready-and-marks` P2.
- No clue generator or pack validation; `SCH-puzzle-def` I1/I3 enforcement stays with the loader
  (#105).
- No screen, input, theme, or persistence code; the board and clue bars are #110's drawing.

## Verdict

All criteria pass, and the graphical screenshots every earlier run was waiting for are in
[`screenshots/`](screenshots/). No defect.
