# Quality evaluator run — issue #693

- **Issue:** #693 Gallery persisted incomplete-only filter toggle (`type:task`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `5259545` (`main`, squash of PR #698, merged 2026-11-06T09:36Z). PRs #697 (`ccc85e6`) and #698 (`5259545`) together are the deliverable; `game/` at `5259545` is the tree measured. `game/` at `5259545` is byte-identical to PR #698's head `771474d` (`git diff 771474d 5259545 -- game/` is empty).
- **Evaluated:** 2026-11-06 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64 (4 cores). Each harness protocol ran under a fresh `user://` (project userdata removed before the run) in a clean clone of `5259545`. No earlier passing record covers `game/` at `5259545` (checked every `docs/quality/evidence/issue-*/**/manifest.md` deliverable commit against `git diff <commit> 5259545 -- game/`), so this is a fresh run.
- **Observation source:** [`integration/results.md`](integration/results.md), from one run each of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `app-start`, `ui-ack`, `solve-reset`, `kill-relaunch`, `paint`, and `navigate`. Raw per-protocol JSON is in [`integration/results/`](integration/results/); `integration/logs/` is gitignored and stays local.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home 2465.5 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`results.md`](integration/results.md); `integration/results/app-start.json` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 29.0 ms. C5's toggle is a non-paint acknowledgement on the same path. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/ui-ack.json` |
| `crash-free` | deterministic | I9: `flows_failed` empty and `crashed` false in `ui-ack`, `solve-reset`, `paint`, and `navigate`; flows ran open, solve, reset, and back. Oracle `flows.solve` reads `{solved_grid: pass, solution_fills: match}` in `solve-reset` and `navigate`. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/{ui-ack,solve-reset,paint,navigate}.json` |
| `resume-after-failure` | deterministic | I10 `kill-relaunch`: launch entry is the shell home (gallery stand-in, `NAV.N1`), reopen `opened: true`, `marks restored: true`, `elapsed restored: true`. | Next launch is gallery; reopen restores marks and elapsed | pass | — | `integration/results/relaunch-verify.json`; `integration/results/kill-relaunch.json` |
| `hitch-bound` | deterministic | I2: longest frame 47.91 ms (`paint`, 203 frames) and 46.44 ms (`navigate`, 247 frames); no hitch above 100 ms. | No hitch longer than 100 ms during grid paint on mid-range phones | pass | — | `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `save-survives` | deterministic | New durable store `user://gallery-prefs.cfg` (`SCH-preferences` F7, ADR-0011). `test_the_toggle_stores_and_restores_after_relaunch` proves the value survives a relaunch; `test_the_shell_applies_the_stored_filter_at_app_start` proves the shell loads it before the gallery shows; `test_a_cold_launch_with_nothing_stored_holds_the_filter_off` proves the cold default is off. Existing `Pack` progress commit path (`ProgressFile.save`) is unchanged by the diff. | Committed progress survives quit, crash, and upgrade | pass | — | `game/test/test_gallery_filter.gd` (GUT, 18/18 on this commit) |
| `failed-write` | deterministic | `test_a_failed_write_leaves_the_previous_document` proves a failed `gallery-prefs` write (unwritable temp path) leaves the previous document loadable; `test_missing_or_unreadable_values_read_as_off` proves a corrupt/empty value reads as off. Existing `ProgressFile` temp+rename is unchanged, and `test_a_failed_write_leaves_the_previous_file` covers it on the same tree. | A failed progress write leaves the previous commit loadable | pass | — | `game/test/test_gallery_filter.gd`; `game/test/test_pack_progress.gd` |

## Not selected

- `frame-time` (I1) — the harness reports I1 `fail` in this folder: `paint` p95 25.00 ms over 203 frames, `navigate` windows gallery 8.87 ms / reveal 19.05 ms (all windows 19.05 ms). The axis is **not** one this deliverable can move: the same `paint` window fails on a baseline three commits before the gallery-filter work — p95 18.11 ms at `2126908` ([`integration/results/paint-baseline-2126908.json`](integration/results/paint-baseline-2126908.json), `I1` fail) — and the dominant cost is the per-mark `ProgressFile.save`, which #699 owns. The gallery window this deliverable draws into is 8.87 ms, under the bar. Recorded for the owning issue, not claimed here.
- `transition-latency` (I7) — `navigate` reports 795.4 ms, but the failing leg is `puzzle-result`, which the harness times across the one-cell-per-frame solve driver (`#700` owns that measurement defect); the product legs are `home-puzzle` and `result-gallery`. This diff adds a 39-px filter row and a label to the gallery and changes no transition.
- `runtime-signals` (I11) — no new telemetry event, log line, or sampler; the filter writes only the preference document.
- Accessibility and localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty.
