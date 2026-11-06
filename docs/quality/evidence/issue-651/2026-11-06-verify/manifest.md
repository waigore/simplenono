# Quality evaluator run — issue #651

- **Issue:** #651 Hint settings: persisted toggles for all hint types (`type:task`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `903b921` (`main`, squash of PR #677). `game/` at `903b921` is the tree measured.
- **Evaluated:** 2026-11-06 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64 (4 cores). Import cache rebuilt (`godot --headless --path game --import`) before the GUT and harness runs. Host shared with other agents; load average read 5.10 during the measurement window.
- **Observation source:** [`integration/results.md`](integration/results.md), from one run each of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `ui-ack`, `solve-reset`, and `paint`, each under a fresh `HOME` (`user://`).

  **GUT caveat:** `game/test/test_settings.gd` does not parse at this commit (duplicate function name,
  `test_desktop_build_has_no_orientation_control` defined at lines 194 and 228). GUT logs
  `Ignoring script res://test/test_settings.gd because it does not extend GutTest` and reports
  `432 / 432 passing`, but only 396 tests executed: the 36 tests from the skipped collector entry are
  counted as passing without running. The settings screen, the subject of this task, therefore has no
  executing test at this commit. Last passing record with a working `test_settings.gd` was `26008cc`
  (parameters 10 settings tests). Details are in the verify comment on #651.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 38.9 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/ui-ack.json` (harness S4 log `integration/logs/harness-1793931305-ui-ack.log` is local only: `logs/` under this root is gitignored and PR-blocked) |
| `crash-free` | deterministic | I9: `flows_ok` = open, solve, reset, back across `ui-ack`, `solve-reset`, and `paint`; no failed flow and no crash in any of the three results. | No crash across open, solve, reset, and back | pass | — | `integration/results/ui-ack.json`; `integration/results/solve-reset.json`; `integration/results/paint.json` |

## Not selected

- `frame-time` (I1) and `hitch-bound` (I2) — these drive the puzzle grid's paint loop. This deliverable adds rows to the
  settings screen and a `present_hints` call in the shell; it touches no grid painting, marking, or layout code. The `paint`
  protocol was run anyway (it also feeds I9); on this contended host its I1 row fails, and the same protocol at the parent
  commit `26008cc` fails by a wider margin, so the spread tracks host load (5.10 on 4 cores), not this diff.
- `transition-latency` (I7) — no new gallery, puzzle, or result transition.
- `time-to-playable` (I6) — the boot path to the gallery is unchanged.
- `resume-after-failure` (I10) — the attempt and progress schemas are unchanged by this deliverable.
- `runtime-signals` (Observability) — no new telemetry event or log line in this diff.
- `save-survives` / `failed-write` (Save durability) — the durable store and write path landed earlier under #660
  (`c2ae719`) and are unchanged here; this deliverable only presents the existing store to the screen.
