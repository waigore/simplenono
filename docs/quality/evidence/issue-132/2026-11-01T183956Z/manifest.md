# Quality evaluator run — issue #132

- **Issue:** #132 Solve loop: get-set-ready, auto-cross (CMP-rules R3), ready edge and elapsed ticking
- **Mode:** `deterministic`
- **Deliverable commit:** `269d854` (`main` HEAD), whose ready-edge surface is PR [#140](https://github.com/waigore/simplenono/pull/140) (`dd0948b`), PR [#147](https://github.com/waigore/simplenono/pull/147) (`9acbb7b`), and the reopened-path repair PR [#160](https://github.com/waigore/simplenono/pull/160) (`5196281`)
- **Runner:** `issue-workflow-verify-agent` (parallel id 1), 2026-11-02

## Results

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence |
|------|-----------|-------------|-----|--------|----------------|----------|
| `resume-after-failure` | deterministic | I10 is `integration`: read the test result. `test_open_in_progress_record_keeps_marks_blocked_until_beat_end` (`game/test/test_open_ready.gd:440`) commits an in-progress record at elapsed 18, opens it on a new `Attempt`, and asserts the `FILL` and 18 restore while `marks_allowed()` is false, `apply_mark`/`mark` write nothing, `advance(3)` leaves 18 and the record is not rewritten, then 18 → 21 only after `end_get_set_ready()`. `test_get_set_ready_on_a_reopened_in_progress_puzzle_stays_blocked` (`game/test/test_puzzle_screen.gd:157`) drives the same reopen through the #110 screen (`S2`, cells `IGNORE`, `0:18` frozen, `0:22` after). Independent probe on a clean `269d854` worktree: the same reopen through the real #112 shell route (`Shell.open_puzzle` → `leave_puzzle` → `open_puzzle`) keeps `S2` blocked and frozen and only opens after the beat. Negative control: the same core-path probe on `881774e` fails 2/4 (224 cells markable during the beat, elapsed +3), so the suite and probe discriminate the outcome. GUT 11 scripts / 139 tests / 139 passing / 29204 asserts, exit 0. | After kill/crash mid-puzzle, next launch is gallery; marks and elapsed restore on reopen | pass | — | `game/test/test_open_ready.gd:440`, `game/test/test_puzzle_screen.gd:157`, rationale in [`rationale.md`](rationale.md) |

## Not selected

`frame-time` (I1), `hitch-bound` (I2) — integration level over paint sampling; the deliverable is the headless `game/play/` ready edge with no paint or render change. `time-to-playable` (I6) — launch to interactive *gallery* is the shell launch path (#94), untouched by #132, #147, or #160. `transition-latency` (I7) — gallery↔puzzle and puzzle→result navigation belongs to #112/#94/#95; #132 delivers no routing. `response-delay` (I8) — non-paint acknowledgement of open/settings/Back belongs to #112/#94; #132's beat is a timed stage, not an acknowledgement. `crash-free` (I9) — the open flow is exercised, but the axis's outcome is a crash-free session length driven by a harness, not a unit run; the deliverable adds no new reachability. `runtime-signals` (I11) — #132 emits one `TEL` line per `Attempt` event on the #169 seams; it neither adds nor removes a signal source, and the axis's remaining quarters are #163's. `save-survives` / `failed-write` (I4) — no `user://` write is added; O4 is read through `Pack.progress()` and O5 in memory only. N/A accessibility and localization axes are not scored.

## Cross-reference

- No cataloged assets added or changed; `review-asset` not applicable.
- `review-code` on the PR #160 diff (the repair this verification covers): **Pass**, no must-fix findings.
- Independent checks on `269d854` (fresh detached worktree): GUT 139/139; PR #140/#147/#160 `Code lint`, `Unit tests`, `Coverage`, `Spec lint`, `PR hygiene` all pass.
- Rationale and limits: [`rationale.md`](rationale.md).

## Verdict

`Pass` — the one selected Applies deterministic axis meets its bar.
