# Quality evaluator run — issue #693

- **Issue:** #693 Gallery persisted incomplete-only filter toggle (`type:task`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `771474d` (PR #698, the verify-Fail fixes; base `main@ccc85e6`)
- **Evaluated:** 2026-11-06 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64, headless, quiet host (4 cores, load average 0.6–0.9).
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>/integration`
  for `app-start`, `paint`, `navigate`, `ui-ack`, `solve-reset`, and `kill-relaunch`, each under a fresh `HOME` (`user://`).

## Prior record

The 2026-11-06 verify report failed on material mockup drift and a `review-code` `CONT` finding,
so it wrote no record. `771474d` adds the renderer changes those findings asked for (a `FilterBar`
row below R1, the hint copy, disabled chrome under `EX.confirm`, and hidden tiles leaving the
focus order at once). No earlier passing record covers this `game/` tree.

## Selection

`game/` at `771474d` differs from `ccc85e6` in three files:
`game/presentation/gallery.gd`, `game/presentation/gallery.tscn`, and
`game/test/test_gallery_filter.gd`. The change adds a filter row, a hint label, a disabled state
for the chrome, and a synchronous detach before `queue_free()` — all on the gallery screen. No
paint, reveal, navigation, launch, or save path changed. The axes that can move are the
gallery-drawing and navigation-flow ones; every Applies deterministic axis was run in this folder
so the record is complete.

## Results

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (menu) 2567.1 ms | ≤ 3 s | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793956708-app-start.log` |
| `frame-time` | deterministic | I1: `paint` p95 22.73 ms over 203 frames; `navigate` p95 gallery 8.33 ms over 70 frames, reveal 21.28 ms over 173 frames (all windows 18.06 ms) over 243 frames | ≤ 16.7 ms during grid paint and navigation | **fail** | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 36.00 ms (`paint`, 203 frames) and 39.27 ms (`navigate`, 243 frames); 0 hitches above 100 ms | No hitch longer than 100 ms during grid paint | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 766.5 ms | ≤ 500 ms | **fail** | — | [`results.md`](integration/results.md); `integration/logs/harness-1793956718-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 31.6 ms | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793956724-ui-ack.log` |
| `crash-free` | deterministic | I9: `paint` (`open`), `navigate` (`open`, `solve`, `back`), `ui-ack` (`open`, `back`), and `solve-reset` (`open`, `solve`, `back`, `reset`) completed; no failed flow, no crashed run | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/solve-reset.json` |
| `resume-after-failure` | deterministic | I10: `kill-relaunch` reported "the mark phase never held" — the record reads `in_progress=true, elapsed=0` while the attempt reads 3 | Next launch is gallery; reopen restores marks and elapsed | **fail** | — | [`results.md`](integration/results.md); `integration/results/kill-relaunch.json` |

## Baseline comparison

The same six protocols were run on `origin/main@ccc85e6` in a clean worktree to see whether the
three failing rows are attributable to this PR:

| Row | `771474d` (PR #698) | `origin/main@ccc85e6` |
|---|---|---|
| app-start I6 | 2567.1 ms — pass | 2354.4 ms — pass |
| paint I1 p95 | 22.73 ms — fail | 20.48 ms — fail |
| navigate I1 gallery p95 | 8.33 ms | 8.16 ms |
| navigate I1 reveal p95 | 21.28 ms | 19.05 ms |
| navigate I1 all windows | 18.06 ms — fail | 18.77 ms — fail |
| navigate I7 longest | 766.5 ms — fail | 794.0 ms — fail |
| kill-relaunch I10 | fail (mark-hold) | not run (fresh worktree) |

`frame-time` fails on both trees with the same two over-budget windows: the paint fill and the
result reveal. The PR adds a 39-px filter row and a label to the gallery; the gallery window is
the one window near the bar (8.33 ms vs 8.16 ms on main — both under it). `transition-latency`
also fails on both trees with the result-reveal stage, which the PR does not touch.
`resume-after-failure` fails in the mark-hold phase; the GUT `test_relaunch_mark.gd` passes 3/3
in process, while the headless child reports
`the progress record reads in_progress true, elapsed 0; the attempt reads 3`. The mark commit
path (`Attempt.mark` → `ProgressRules.commit`) is not touched by this PR.

Per [`docs/issues/workflow-deterministic-record.md`](../../../../../docs/issues/workflow-deterministic-record.md)
and [`verify-project-issue`](../../../../../.agents/skills/verify-project-issue/SKILL.md), a
**fail** row fails verification whether or not it predates the change. This record reports the
rows as observed. A repeated run of `paint` and `navigate` on `771474d` reproduced all three: p95
25.00 ms (`paint`), gallery 8.05 ms / reveal 24.90 ms / windows 23.33 ms (`navigate`), and
850.3 ms (`transition-latency`). The prior verify run of `2c88766` recorded paint p95 25.00 ms,
navigate reveal p95 22.22 ms, and 899.1 ms, so the magnitudes are stable across days and commits.

## Not selected

- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).
- `save-survives` and `failed-write` (I4) — `771474d` changes no save, commit, or `user://`
  path: `game/records/` and `game/play/` are identical to `ccc85e6`, and the gallery preference
  document (`gallery-prefs.cfg`) was covered by the original #693 change. The `solve-reset`
  protocol's solve/reset/quit row is cited in [`results.md`](integration/results.md) for context.
- `runtime-signals` (I11) — the smoke observables are in `integration/logs/`; no log, sampler, or
  telemetry source changed.

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
