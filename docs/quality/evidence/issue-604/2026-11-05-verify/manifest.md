# Quality evaluator run — issue #604

- **Issue:** #604 Integration harness kill-relaunch: elapsed leg never restores, so I10 fails at base (`type:task`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `713e0de` (`main` at verification, 2026-11-05; #604 shipped as PR #615). `game/` at `713e0de` is the tree the harness ran.
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64 (4 cores, load average 0.9–2.3 during the runs). A fresh `HOME` gave each run its own `user://`.
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=kill-relaunch --run-dir=<this folder>`
  under a fresh `HOME`, plus the GUT suite
  `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` (32 scripts, 387 tests,
  387 passing, 21 302 asserts, exit 0) and the probes noted below.

The deliverable is harness work under `game/test/`: `IntegrationRelaunchMark` (`relaunch_mark.gd`) holds the mark
phase's order (open → end get-set-ready → advance → committing mark), `relaunch_child.gd` writes its marker only
after that commit, and the verify phase judges `elapsed_restored` as `elapsed == marker.elapsed` with
`marker.elapsed > 0`. Nothing under `game/play/` changed (`git diff 4421dee 713e0de -- game/play/` is empty), so the
product's reopen-and-restore path is untouched.

This run tests the I10 row the issue exists to make honest: before the fix the same command on this tree read
`elapsed restored: false` and I10 failed on every run.

No existing passing record covers `game/` at `713e0de`. The nearest, #562's record
([`issue-562/2026-11-05-verify`](../../issue-562/2026-11-05-verify/manifest.md)) is at `73c8c41`, which diffs
against this tree in 18 `game/` files, and it recorded I10 as failing rather than passing. This is a fresh run:

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `resume-after-failure` | deterministic | I10 (`integration`, read from the test result): `kill-relaunch` exited 0 with `launch entry: gallery stand-in (shell home); reopened: true; marks restored: true; elapsed restored: true`. `logs/relaunch-mark.json` reads `elapsed: 3` at `(0, 0)`; `logs/relaunch-verify.json` reads `elapsed_restored: true`, `marked_elapsed: 3`, `pass: true`. The committed record agrees: `logs/state-pack-000.json` `progress.elapsed` is 3 with `progress.in_progress: true` and a `fill` at the marker's cell, and `attempt.elapsed` is 3 beside it. | After kill/crash mid-puzzle, next launch is gallery; marks and elapsed restore on reopen | pass | — | [`results.md`](integration/results.md); `integration/results/kill-relaunch.json`; `integration/logs/relaunch-verify.json`; `integration/logs/state-pack-000.json` |

## Probes (not scoring rows)

Independently of the implementor's claims, two checks were re-run against the same tree:

- **The new test fails on the old order.** With `advance` moved after `mark` inside `relaunch_mark.gd`,
  `test_relaunch_mark.gd` fails: "the mark did not persist: the progress record reads in_progress true, elapsed 0;
  the attempt reads 3". Reverted afterwards; the working tree is clean at `713e0de`.
- **The leg does not pass on a constant.** Against a `user://` that already holds the record, the verify phase with
  the marker file deleted and with `elapsed: 0` both write `elapsed_restored: false`, `pass: false`, and exit 1,
  while `marks_restored` stays true — so only the elapsed leg moves.

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint, sampler, or layout path changed.
- `time-to-playable`, `transition-latency`, `response-delay` (I6, I7, I8) — no launch or navigation leg changed.
- `crash-free` (I9) — the deliverable edits the `kill-relaunch` child and marker only; the open/solve/reset/back
  flows it would need are unchanged and covered by their own records.
- `runtime-signals` (I11) — the child's `print` line and marker fields are harness output, not the S4 telemetry
  source; no event, sampler, or severity source changed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
