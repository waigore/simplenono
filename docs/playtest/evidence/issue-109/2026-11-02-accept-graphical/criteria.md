# Acceptance criteria — issue #109

Build `main@dcd9a24`, session `issue-109-capture`. Evidence paths are relative to this folder.

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` exits 0 with 0 failing, including `test_solve_edge.gd` | **Pass** | [`logs/gut-suite.log`](logs/gut-suite.log): 11 scripts, 142 tests, 142 passing, 0 failing, 29 229 asserts, exit 0 |
| 2 | `PS1.4` — marks allowed, one fill differs from the solution: `is-solved` false, the fill unchanged, attempt in progress, no O6, no E1 | **Pass** | checks `PS1.4: …` in [`logs/capture-console.log`](logs/capture-console.log); [`00`](screenshots/00-wrong-fill-playable.png) |
| 3 | `PS1.5` — a fill completes the solution: elapsed stops, O6 once with the stopped elapsed, E1 the same payload, the return carries the pre-clear grid and line status, then not started with clear marks and elapsed 0 | **Pass** | `S1/P1: E1 carries the puzzle id and the stopped elapsed ([["pack-000", 59]])` plus the `capture: P1 record=59 inspect=…` line (record `in_progress: false`, `marks: null`, `elapsed: 0`, `personal_best: 59`); [`02`](screenshots/02-near-solve-pb-none.png) → [`03`](screenshots/03-first-solve.png) |
| 4 | `PS1.6` — ever-completed true, PB 30, solved at 50: O6 receives 50, PB stays 30, ever-completed stays true | **Pass** | `P2` checks: a `10:00` replay against PB 59 kept PB 59 and `ever_completed` true; `P3` then replaced it with 8. [`04`](screenshots/04-longer-replay-near-solve.png) → [`05`](screenshots/05-longer-replay-keeps-pb.png) |
| 5 | `CTR-attempt` G1 — a mark while blocked or paused changes no marks, runs no solve check, emits no E1 | **Pass** | `G1: …` checks for both the beat (`grid unchanged while blocked`, `no record write while blocked`) and the pause (`while paused`); [`01`](screenshots/01-paused-mark-blocked.png) |
| 6 | `SEQ-mark` B3 — on the solve branch the commit (O5) is skipped and O6 is used; every other mark path commits through O5 and does not call O6 | **Pass** | `B3: a non-solving accepted mark commits through O5` (record signature changed) plus the post-solve record with no marks and `in_progress: false`; the O5-not-called half is asserted in `game/test/test_solve_edge.gd` (`RecordingProgress.commit_calls`) because the record alone cannot show an unused call |
| 7 | No progress record written outside O5/O6; `game/presentation/`, `game/main.tscn`, and `user://progress.cfg` handling unchanged (so the `MC.puzzle` gate does not apply) | **Pass** | [`logs/criteria-greps.log`](logs/criteria-greps.log): the deliverable commit `2eb2f12` touches only `game/play/attempt.gd`, `game/play/mark_result.gd`, and `game/test/test_solve_edge.gd`; the only `record_solve`/`commit` are `CTR-pack` O5/O6 in `game/records/progress_rules.gd`; no `user://` write exists in shipped code (comment only) |
| 8 | `PS1.1`, `PS1.2`, `PS1.3` not asserted; `PS1.1`/`PS1.9` named to the ready leaf, `PS1.2`/`PS1.7`/`PS1.8` to #96, `PS1.3` to #108 | **Pass** | `game/test/test_solve_edge.gd` header (lines 13-16) names the owners; the body's out-of-scope table agrees; no probe check asserts those ids |

## Not asserted here, by design

`PS1.1` / `PS1.9` (ready edge, auto-cross) are #132's, judged graphically in
[`issue-132/2026-11-02-accept-graphical`](../../issue-132/2026-11-02-accept-graphical/manifest.md).
`PS1.2` / `PS1.7` / `PS1.8` (elapsed restore, ticking, pause/leave) are #96's. `PS1.3` (first-mark
transition and the derived rules) is #108's, judged graphically in
[`issue-108/2026-11-02-accept-graphical`](../../issue-108/2026-11-02-accept-graphical/manifest.md).
