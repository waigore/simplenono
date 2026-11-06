# Quality evaluator run — issue #651

- **Issue:** #651 Hint settings: persisted toggles for all hint types (`type:task`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `f61b1f6` (`main`, current head at verify time). `game/` at `f61b1f6` is the tree measured.
- **Evaluated:** 2026-11-06 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64 (4 cores), load average 0.79–1.80. Import cache rebuilt (`godot --headless --path game --import`) before the harness runs. This re-run supersedes the `2026-11-06-verify` record: that record measured `903b921`, and `game/` has since changed (`git diff 903b921 f61b1f6 -- game/` is not empty; the dedup of `test_settings.gd` and the #652 overlay work landed), so it no longer covers this tree per the evidence README reuse rule.
- **Observation source:** [`integration/results.md`](integration/results.md), from one run each of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `ui-ack`, `solve-reset`, and `paint`, each under a fresh `HOME` (`user://`).

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 28.5 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/ui-ack.json` (harness S4 log `integration/logs/harness-1793940580-ui-ack.log` is local only: `logs/` under this root is gitignored and PR-blocked) |
| `crash-free` | deterministic | I9: no crashed run and no failed flow in any of `ui-ack` (back, open), `solve-reset` (back, open, reset, solve), and `paint` (open). | No crash across open, solve, reset, and back | pass | — | `integration/results/ui-ack.json`; `integration/results/solve-reset.json`; `integration/results/paint.json` |

## Not selected

- `frame-time` (I1) and `hitch-bound` (I2) — these drive the puzzle grid's paint loop. This deliverable adds rows to the
  settings screen and a `present_hints` call in the shell; it touches no grid painting, marking, or layout code. The `paint`
  protocol was run anyway (it also feeds I9). Its I1 row reads 21.21 ms on this 4-core host, and the pre-#651 baseline tree
  (`c2ae719`) measures a worse 24.37 ms under the same conditions, so the I1 spread tracks the host and pre-exists this
  deliverable. No settings code is on that path.
- `transition-latency` (I7) — no new gallery, puzzle, or result transition.
- `time-to-playable` (I6) — the boot path to the gallery is unchanged.
- `resume-after-failure` (I10) — the attempt and progress schemas are unchanged by this deliverable.
- `runtime-signals` (Observability) — no new telemetry event or log line in this diff.
- `save-survives` / `failed-write` (Save durability) — the durable store and write path landed earlier under #660
  (`c2ae719`) and are unchanged here; this deliverable only presents the existing store to the screen.
