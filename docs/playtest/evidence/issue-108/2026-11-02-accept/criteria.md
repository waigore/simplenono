# Acceptance criteria — issue #108

Judged at `main@67e36f5`. Deliverables: PR #133 (`04b1510`) and PR #158 (`6eeef24`). Logs under
`logs/`; probe source [`probe-accept-108-gs.gd`](probe-accept-108-gs.gd).

| # | Acceptance criterion | Outcome | Evidence |
|---|----------------------|---------|----------|
| 1 | `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` exits 0 with 0 failing tests, including `game/test/test_game_state.gd` | **pass** | [`logs/gut-accept.log`](logs/gut-accept.log) — 10 scripts, 125/125, 29050 asserts, exit 0 |
| 2 | `CTR-rules` O1 true when fills equal the solution with crosses elsewhere; O2 returns one `SCH-line-status` per row and column with F3/F4 matching `row-error` / `col-error` / `clue-satisfied` (`PS1.1`, `PS1.3`, `PS1.3b`, `PS1.4`, `PS1.4b`) | **pass** | [`logs/probe-gs.log`](logs/probe-gs.log) `test_derived_values_from_the_rules` — solve with crosses; extra fill false; row 4/column 6 possible; empty column 0 in error; row 4 exact satisfied vs. diverged not |
| 3 | No derived value is stored: `game/play/` and `game/records/` expose error/satisfied/solved as computed returns; `rules.gd` writes neither grid nor record | **pass** | Probe `test_rules_store_nothing` — grid snapshot unchanged after three rule calls; `solution_fills()` copy; [`logs/criteria-greps.log`](logs/criteria-greps.log) finds no record field writes outside `progress_rules.gd` |
| 4 | Attempt-status transitions match the field table: first accepted mark or empty-line auto-cross → in progress; a mark while blocked/paused changes nothing; solve and reset → not started | **pass** | Probe `test_attempt_status_transitions` — blocked reject, fill start, paused reject + no write, clear → not started, elapsed 0, auto-cross start |
| 5 | `GS.completion-rate` = ever-completed ÷ pack size for a fixture pack of any size; O1 thumbnail flag true exactly when ever-completed | **pass** | Probe `test_progress_values` — 3/10, 3/4, 3/200, empty 0.0; flag false → true → false |
| 6 | `GS.personal-best` replaced only when shorter; `V1`–`V6` each have a named GUT test; no path writes `SCH-progress` outside O5–O7 | **pass** | Probe (30 → 40 keeps 30, → 20 replaces); [`logs/criteria-greps.log`](logs/criteria-greps.log) — no writes outside `progress_rules.gd`; `V1`–`V6` named in `test_game_state.gd` |
| 7 | No screen or input delivered: `game/presentation/` and `game/main.tscn` unchanged, no scene/input code | **pass** | [`logs/criteria-greps.log`](logs/criteria-greps.log) — `04b1510` touches `game/play/`, `game/records/`, `game/test/` only; `6eeef24` touches one test file |
| 8 | Deferred `PS1.2` (200 ever-completed) and `PS1.5` (shipped picture) named as deferred to #94 / #97 / #98 | **pass** | [`logs/criteria-greps.log`](logs/criteria-greps.log) — named in `progress_rules.gd` and `test_game_state.gd` |

## Playtest gate

`GS` is a playtestable design story owned by #108, so `PTD-ready-and-marks` applies. The headless
run judged the protocol's `GS` clauses at the seam; its graphical steps need `DBG.3` / `DBG.2`,
which do not exist on this build. Screenshots are therefore **waiting**, which is not a protocol
fail and files no defect ([`evidence.md`](../../../../../specs/playtest/evidence.md)). Acceptance
stays on `status:pending-acceptance` until a graphical re-run of the same build can photograph the
judged states.

## Quality axes

N/A. The deliverable keeps progress in memory only and adds no frame, hitch, launch, transition,
persistence, or crash surface, so no Applies deterministic axis can move; no `llm-judge` axis
applies. No `deterministic` record is owed for #108.
