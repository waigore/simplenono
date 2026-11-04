# Quality evaluator run — issue #550

- **Issue:** #550 Integration harness solve flow: filling the solution intermittently does not solve the puzzle on main (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `9604775` (PR #555 head `task/550-solve-oracle` — the oracle, determinism, and lane-rule work merged with `origin/main` at `3288a38`, which is the merge base, so the reviewed tree is the shipped tree).
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on macOS arm64.
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `app-start`, `paint`, `ui-ack`, `navigate`, `solve-reset`, and `kill-relaunch`, each under a fresh `HOME` (`user://`),
  on a quiet host (load average 1.37–1.58 per run).
- **No existing record covers `game/` at `9604775`:** the nearest deterministic records are #540 at `e05e4e0` and #539 at the
  pre-`#562` tree; `git diff <recorded> <deliverable> -- game/` is non-empty for both (`#562` changed `game/play/`), so this is a
  fresh run rather than a reuse.

Selected axes: the harness deliverable moves the solve and lane observations, so the selected deterministic axes are the ones
whose observation the deliverable changes — `time-to-playable` (I6 lane rule), `transition-latency` (I7, the `puzzle-result`
leg completes), `response-delay` (I8 lane rule), and `crash-free` (I9, the solve flow now judged by `flows.solve`). The unit
evidence (`game/test/`) on the same tree is 365/365 over 31 scripts, including the 7 `test_solve_oracle` cases and the 4
`test_lane_recording` cases (AC 2 and AC 3b's tests).

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery): 271.3 ms. | ≤ 3 s | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793809670-app-start.log` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery`: 215.3 ms (compose run) and 207.4 / 207.9 / 215.1 / 218.3 ms across 4 fresh-`HOME` dedicated `navigate` runs. | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793809674-navigate.log`; run folders `/tmp/opencode/qe550/ac3a/run-1..4` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings`: 7.4 ms. | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793809673-ui-ack.log` |
| `crash-free` | deterministic | I9: all four flows ran in this folder with no crash and no failed flow. The solve flow is judged from `flows.solve`: every run in this folder and in an 8-run dedicated set (fresh `HOME`, load 1.77–1.89, dirs `/tmp/opencode/qe550/ac1b/run-1..8`) reads `{"solved_grid": "pass", "solution_fills": "match"}`, cited from the per-run `integration/results/solve-reset.json`, never from the absence of a failed row. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/solve-reset.json` |

Dedicated run sets (fresh `HOME` and fresh run folder each, `--debug-seams`, load recorded before every run):

- **AC 1** — `solve-reset` ×8 on this head: 8/8 exit `0`, load 1.77–1.89, every run `flows.solve = {"solved_grid": "pass", "solution_fills": "match"}`. A first batch of 8 at load 2.56–2.79 was discarded under the discard rule (host was not quiet) and is not evidence for any claim.
- **AC 3a** — `navigate` ×4: 4/4 exit `0`, load 1.72–1.85, every `I7` row passes and the `puzzle-result` leg completes (207.4–218.3 ms); no `protocol failed: puzzle-result`.
- **Before-fix counts:** a fresh reproduction of the flake was not obtained on this host on the unfixed harness (8 pass at the branch point, as the PR body records); the last observed failure baseline stands — the #540 manifest, `main` at `65cf688`: 6 of 8 `solve-reset` runs failed with the bare sentence. The oracle's own failing proof stands as recorded in the PR body and in the #550 verification-fail comment of 2026-11-04: a paused (refused-fill) `solve-reset` run on the fixed harness fails with `no solve of pack-000: the fill was refused; (2, 4): marks were blocked when the fill was applied, so it was refused and nothing was written` and `flows.solve = {"solved_grid": "refused", ...}` — the bare sentence is gone.

## Not selected

- `frame-time` (I1) / `hitch-bound` (I2) — the deliverable changes no sampling or paint path; both rows report pass in `results.md` for completeness (`paint` p95 6.94 ms, `navigate` walls 6.94–6.98 ms, longest frame 10.62 ms).
- `resume-after-failure` (I10) — the `kill-relaunch` protocol fails on this macOS host with the relaunch driver error `The process … does not exist or is not a child of the calling process` (`integration/logs/harness-1793809679-kill-relaunch.log`), and the same protocol fails identically at the base `3288a38` (same host and command), so the failure is a host limitation of the relaunch driver, and the harness-only deliverable cannot change the axis's outcome. Recorded here as an observation, not as a scoring row.
- `save-survives` / `failed-write` (I4) and `runtime-signals` (I11) — the deliverable touches no persistence or telemetry path; their behaviors are unchanged on this tree.

## Noted while running (not a scoring row)

A run whose `user://` carries a restored in-progress board (e.g. a host `user://` reused across runs, which the AC's fresh-`HOME`
rule excludes) fills nothing and refuses nothing, so `compare()` reads `absent` ("no fill was written") while the board holds the
leftover marks; the pass/fail outcome stays correct (the step fails), but the message and `solution_fills` summary name no fills a
board visibly held (`flows.solve` recorded `absent` with all solution cells listed as unfilled). The oracle compares only the grid
the solve carried and the recorded refusals — it has no live-grid input. Reported as a review-code suggestion on this record run;
see the #550 verification comment.
