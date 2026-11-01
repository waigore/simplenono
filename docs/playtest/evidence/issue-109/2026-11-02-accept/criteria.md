# Criteria — #109 accept

Checked against `main@fa6fe3e` in a clean detached worktree. `#145` is the only commit since the verified merge `22654c9` and edits a doc comment only, so the behaviour judged is the verified tree.

| # | Criterion | Verdict | How it was checked | Evidence |
|---|-----------|---------|--------------------|----------|
| 1 | Suite exits 0 with 0 failing, incl. `test_solve_edge.gd` | Pass | **8 scripts, 122 tests, 122 passing, 0 failing, 29269 asserts, exit 0**. Script and test counts read from the report, not only the exit code, so no file was silently skipped | `logs/gut-accept.log` |
| 2 | `PS1.4` — wrong fill unchanged, not solved, in progress, no O6/E1 | Pass | Off-solution clear cell filled at elapsed 50 stays filled; `is_solved` false; no E1; record stays in progress at 50; clock still running | probe log |
| 3 | `PS1.5` — clock stops, O6 once, E1 same payload, pre-clear return, then not started / clear / 0 | Pass | Record `{ever_completed: true, in_progress: false, personal_best: 50, elapsed: 0, has_marks: false}`; attempt not started at 0, no marks; E1 once as `["teapot", 50]`; returned grid keeps the solving fill. Line status in the return: `test_the_solve_returns_the_pre_clear_grid_and_line_status` | probe + suite logs |
| 4 | `PS1.6` — ever-completed true, PB 30, solved at 50 | Pass | Replay path: PB 50, solved at 100 → PB stays 50, ever-completed true, not started. Mutation 1 proves the branch is decided by the shipped PB rule | probe + mutation logs |
| 5 | `CTR-attempt` G1 — blocked or paused fill changes nothing, no solve check, no E1 | Pass | Paused: grid and returned grid unchanged, no E1, no solve, stored elapsed untouched, clock frozen. Blocked: `test_a_mark_while_marks_are_blocked_changes_nothing` | probe + suite logs |
| 6 | `SEQ-mark` B3 — solve skips O5 uses O6; other marks use O5 | Pass | Structural: solve → *solved* record (O6 only); non-solving mark → *in-progress* record with running elapsed (O5 only). Mutation 2 makes the solve fall through to O5 and the probe catches every P1 symptom | probe + mutation logs |
| 7 | No writer outside O5/O6; `game/presentation/`, `main.tscn`, `user://` unchanged | Pass | UI diff empty; the only `user://` mention is the comment saying the progress file is not built. `ProgressRules` is the only writer. No UI, so the `MC.puzzle` gate does not apply | `logs/criteria-greps.log` |
| 8 | `PS1.1`/`PS1.2`/`PS1.3` not asserted; owners named | Pass | The test header names `PS1.1`/`PS1.9` → #132, `PS1.3` → #108, and `PS1.2`/`PS1.7`/`PS1.8` → #96, matching the body's out-of-scope table. None of those scenarios is asserted in this file | `game/test/test_solve_edge.gd` 13–17 |
