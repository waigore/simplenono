# Quality evaluator run — issue #317

- **Issue:** #317 Drive the result screen back (`NAV.T5`) after solve in solve-reset (`type:task`, parent #96)
- **Mode:** `deterministic`
- **Deliverable commit:** `ace1463` (`main`, squash of PR #330; `game/` at `ace1463` is identical to the measured
  branch head `f45c58e` — `git diff f45c58e ace1463 -- game/` is empty).
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=solve-reset --run-dir=<this folder>`
  with an isolated `HOME` (fresh `user://`), plus the PR's `Integration harness` check
  ([run 41426743436](https://github.com/waigore/simplenono/actions/runs/41426743436)).

Selected axis is the only Applies deterministic axis this deliverable can move: the change replaces an
out-of-spec post-solve `leave` drive with the result screen's `C1` back and its `S1` wait, so the `solve-reset`
run now completes all four `crash-free` flows (I9). The change is confined to the integration harness
(`game/test/integration/`); it adds no per-frame work, no launch work, no timed transition, no persistence path,
and no resume path.

No existing record covered `game/` at `ace1463`: the #312 record (`fcd899e`) predates this deliverable's
harness change, so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `crash-free` | deterministic | I9: `solve-reset` exits 0 with a fresh `user://`; flows `open`, `solve`, `reset`, `back` all pass, `flows_failed` is empty and `crashed` is false. The recorded drive order is `open`, `solve`, `result-default` (900 ms), `result-back`, `result-view` (`view=gallery`), `reopen`, `mark`, `reset`, `back`, `quit` — no post-solve `leave`. | No crash across open, solve, reset, and back | pass | — | `integration/results.md`; `integration/results/solve-reset.json` |

## Not selected

- `frame-time` (I1), `hitch-bound` (I2) — the deliverable adds no paint or navigation work; it only reorders
  harness steps. The render loop is unchanged.
- `time-to-playable` (I6) — no launch path changed.
- `transition-latency` (I7) — the result→gallery leg is driven, not timed, in `solve-reset`; `navigate` owns the
  measurement and its code is untouched.
- `response-delay` (I8) — no acknowledgement path changed.
- `resume-after-failure` (I10) — no resume path changed; `kill-relaunch` is untouched.
- `runtime-signals` (I11) — no log, sampler, or telemetry source was added or removed; the `leave` TEL event
  still comes from the post-reset puzzle leave.
- `save-survives`, `failed-write` (I4) — no persistence path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.

## Verdict

`Pass` — the selected Applies deterministic axis is observed and within its bar; no row is `fail` or `blocked`.
