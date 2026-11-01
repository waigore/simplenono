# Criteria — issue #108

Each acceptance criterion of #108, the story it traces to, and where the graphical run judged it.
Screen values come from `godot --path game` on `main@1015ee9` (session `issue-108-capture`); the
console is [`logs/capture-console.log`](logs/capture-console.log).

| # | Criterion (issue) | Traces to | Verdict | Evidence |
|---|-------------------|-----------|---------|----------|
| 1 | Unit tests exit 0 with 0 failing, including `game/test/test_game_state.gd` | — | **Pass** | [`logs/gut-suite.log`](logs/gut-suite.log): 11 scripts, 139/139, 29 204 asserts, exit 0 |
| 2 | `CTR-rules` O1/O2 — `is-solved`, line status, crosses ignored | `PS1.1`, `PS1.3`, `PS1.3b`, `PS1.4`, `PS1.4b` | **Pass** | `01`/`02`: the unsolved board is not solved; a wrong fill stays and does not solve; `2 × size` statuses; screenshot [`02`](screenshots/02-wrong-fill-playable.png) |
| 3 | No derived value stored; `Rules` writes neither grid nor record | `SCH-attempt` I1, `CTR-rules` G3 | **Pass** | grid signature unchanged across `is_solved` + `line_status`; no `solved` / `is-solved` / `line-status` / `row-error` / `col-error` / `satisfied` key in the record |
| 4 | Attempt-status transitions per the field table | `PS1.6`, `V2`, `V3` | **Pass** | `00`: fresh open not started, blocked, `0:00`; after the tap the grid is unchanged; first fill → `in_progress`; a blocked mark changes nothing |
| 5 | `completion-rate` = ever-completed ÷ pack size; thumbnail flag exactly on ever-completed | `PS1.2`, `PS1.5`, `H1` | **Pass** | rate `0.0` with nothing completed; flag hidden → visible when `ever_completed` set → hidden when cleared. 200-puzzle proof deferred (#94/#97/#98) |
| 6 | Personal best only shrinks; `V1`–`V6` named GUT tests; reset clears | `V1`, `V4`, `V6` | **Pass** | PB rule asserted by `test_game_state.gd::test_a_solve_sets_ever_completed_with_a_personal_best` (`V4`); at runtime by #109's `PTD-solve-and-pb`; reset proven in `04` |
| 7 | No screen or input delivered; `PS1.2` / `PS1.5` deferrals named | scope boundary | **Pass** | `game/presentation/` untouched by the deliverable; deferrals named in `test_game_state.gd` and `progress_rules.gd` |

## Playtest scope

| Story or protocol | Outcome | Image / log |
|-------------------|---------|-------------|
| `PTD-ready-and-marks` S1 | pass | [`00`](screenshots/00-fresh-ready-blocked.png) |
| `PTD-ready-and-marks` S2 | pass | [`01`](screenshots/01-ready-fill-clear-cross.png) |
| `PTD-ready-and-marks` S3 | pass | [`02`](screenshots/02-wrong-fill-playable.png) |
| `GS` P2 (empty-clue auto-cross) | pass | `01`: rows 0 and 9 crossed |
| `PS1.7` / `Q1` determinism | pass | identical outcome over two real opens |
| `V3` reset | pass | [`04`](screenshots/04-after-reset.png) |
| `PTD-ready-and-marks` S4 / P3 pause | not this task | judged by #132 / #156 |

`PS1.2`'s 200-puzzle content proof and `PS1.5`'s shipped generated picture are **deferred** to
#94 / #97 / #98, as the issue body records; the completion-rate arithmetic and the flag mapping are
proved here.
