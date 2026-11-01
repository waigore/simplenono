# Quality evaluator run — issue #156

- **Issue:** #156 Reopened in-progress puzzle allows marks during get-set-ready
- **Mode:** `deterministic`
- **Deliverable commit:** `8adb1546d6afa551cf5ce142d96d30411358e9b9` (PR #160, open, not merged)
- **Runner:** `issue-workflow-verify-agent` (parallel id 1), 2026-11-02

## Results

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence |
|------|-----------|-------------|-----|--------|----------------|----------|
| `resume-after-failure` | deterministic | I10 is `integration`: read the test result. `test_open_in_progress_record_keeps_marks_blocked_until_beat_end` drives `pack.progress().commit(...)` → `Attempt.open` across a discarded attempt and asserts marks restore (`FILL` at `ROW_SEVEN,2`), elapsed restores at `18`, marks stay blocked through the beat, and elapsed ticks 18 → 21 only after it ends. `test_get_set_ready_on_a_reopened_in_progress_puzzle_stays_blocked` drives the same reopen through the screen (S2, elapsed `0:18` frozen, `0:22` after). Before the fix, reverting only `progress_record.gd`/`progress_rules.gd` to `main` under the same tests fails exactly those 3 new tests (120/123), so the restore outcome this deliverable moves is observed, not assumed. GUT 123/123, 29032 asserts, exit 0. | After kill/crash mid-puzzle, next launch is gallery; marks and elapsed restore on reopen | pass | — | `game/test/test_open_ready.gd:440`, `game/test/test_puzzle_screen.gd:113`, `/tmp/v156_gut.log`, `/tmp/v156_revert.log` |

## Not selected

`frame-time` (I1), `hitch-bound` (I2), `time-to-playable` (I6), `transition-latency` (I7), `response-delay` (I8) — no paint, launch, or navigation change; the diff touches `game/play/` grid construction and `game/records/` copies only. `crash-free` (I9) — same reasoning; the PR changes no flow reachability. `runtime-signals` (I11) — no log, sampler, or telemetry call added or removed. `save-survives` / `failed-write` (I4) — the commit path is unchanged; `_copy_of` changes only the marks-allowed flag on an in-memory stored grid, not the persisted schema or write. N/A accessibility and localization axes are not scored.

## Cross-reference

- No cataloged assets added or changed; `review-asset` not applicable.
- `review-code` on the PR #160 diff: **Pass**, no must-fix findings.
- Independent checks on the PR head (`8adb154`): GUT 123/123; `gdformat --check game` 36 files unchanged; `gdlint game` clean; CI `Code lint`, `Unit tests`, `Coverage`, `Spec lint`, `PR hygiene` all pass.
- Rationale and limits: [`rationale.md`](rationale.md).

## Verdict

`Pass` — the one selected Applies deterministic axis meets its bar.
