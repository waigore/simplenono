# Acceptance record — issue #166

- **Issue:** #166 Integration harness for the Applies integration-level quality invariants
- **Mode:** headless acceptance re-run (not a quality-evaluator run; see [Why there is no `manifest.md`](#why-there-is-no-manifestmd))
- **Deliverable:** `main` at `66c6363` (contains #173 → #182 and the merged PR #182 / `110b3ce`)
- **Run folder:** [`integration/`](integration/) — written by the harness itself, unexplained
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-02

## What was run

Protocols were driven from a detached worktree of `origin/main` (`66c6363`) with
`godot --headless --path game --import` once, then one harness invocation per
protocol into a single run folder:

| Protocol | Flags | Exit |
|----------|-------|------|
| `self-test` | — | **0** |
| `app-start` | `--debug-seams` | **0** |
| `paint` | `--debug-seams` | **0** |
| `navigate` | `--debug-seams` | **1** |
| `ui-ack` | `--debug-seams` | **0** |
| `solve-reset` | `--debug-seams` | **0** |
| `kill-relaunch` | `--debug-seams` | **1** |

Extra probes:

- `--protocol=paint` with no `--debug-seams`: **exit 2**, message `the debug seams are off; game protocols run only against the debug build with --debug-seams (verification.md H2).`, and **no run folder** created.
- `samples/paint-samples.ndjson`: **203** lines (200 grid marks + 3 pause frames).
- `logs/relaunch-verify.json`: `gallery_entry: true`, `opened: true`, `marks_restored: false`, `elapsed_restored: false`, `pass: false`.
- Run folder holds `results.md`, `results/`, `samples/`, `logs/` only — **no `manifest.md`**.
- Per-protocol stdout/stderr is kept as `integration/logs/accept-<protocol>.stdout.log`.

## Results table

Reproduced verbatim from [`integration/results.md`](integration/results.md).

| Protocol | Invariant | Axis | Result |
|----------|-----------|------|--------|
| app-start | I6 | `time-to-playable` | pass — 185.6 ms to the interactive shell home (gallery stand-in until #94) |
| paint | I1 | `frame-time` | pass — p95 6.94 ms over 203 frames |
| paint | I2 | `hitch-bound` | pass — longest frame 7.91 ms over 203 frames |
| paint | I9 | `crash-free` | pass — open, solve, reset, back |
| navigate | I7 | `transition-latency` | fail — `puzzle-result` not acknowledged within 2000 ms (#95); `result-gallery` marked driver-timed |
| navigate | I9 | `crash-free` | pass |
| ui-ack | I8 | `response-delay` | pass — longest 7.8 ms |
| ui-ack | I9 | `crash-free` | pass |
| solve-reset | I9 | `crash-free` | pass |
| kill-relaunch | I10 | `resume-after-failure` | fail — reopened; marks and elapsed not restored (#96) |
| self-test | — | — | pass |

## Acceptance criteria

| # | Criterion | Result |
|---|-----------|--------|
| 1 | One command runs one named protocol, exits nonzero on protocol failure | **Pass** — 0 / 1 / 2 all reproduced |
| 2 | `frame-time` and `hitch-bound` reduced from real per-frame samples in `integration/samples/` NDJSON | **Pass** — 200 distinct per-frame marks + 3 pause frames; numbers come from the NDJSON |
| 3 | `app-start`, `navigate`, `ui-ack` measure `time-to-playable`, `transition-latency`, `response-delay` between explicit marks matching I6/I7/I8 | **Pass mechanically** — every leg crosses a frame and waits on the product probe; the `navigate` timeout and the `driver_time` note are recorded rather than timed as driver CPU |
| 4 | `kill-relaunch` reproduces I10 (kill, relaunch to gallery, reopen observes marks/elapsed) | **Pass as the harness obligation** — real kill, relaunch, gallery entry and reopen observed; restores recorded as false. Restore itself is #96's |
| 5 | Nonzero exit / script error reported as a `crash-free` observation, not a harness error; `crash-free` passes only when all four I9 flows ran | **Pass** — `navigate` exited 1 and the folder still records `crash-free: pass` with open, solve, reset, back |
| 6 | I1, I2, I6–I10 each claimed; `results.md` lists every protocol × invariant row with pass/fail and artifact | **Pass** — 10 game rows + guarded `self-test` row; I9 claimed by four protocols |
| 7 | Quality run writes `integration/{results.md,samples,logs}` and never `manifest.md`; an evaluator cites that run for an Applies axis without `blocked` | **Pass** — layout verified; [`issue-110` run `2026-11-01T190448Z`](../issue-110/2026-11-01T190448Z/manifest.md) cites an `issue-110` harness run for `frame-time` / `hitch-bound` / `time-to-playable` / … without a `blocked` row |
| 8 | Debug flag off → game protocol exits nonzero with a clear message and writes no run folder; no second flag | **Pass** — exit 2, message names H2, no folder, `--debug-seams` is #163's single flag |
| 9 | `self-test` passes in CI as `Integration harness` without S1–S5; no game protocol required in CI | **Pass** — `self-test` exit 0; the six game protocols are documented as not CI-required |
| 10 | `docs/coding-conventions.md`, `docs/quality/evidence/README.md`, `specs/technical/verification.md` name the command and layout | **Pass** — [`integration-harness.md`](../../../coding-conventions/integration-harness.md), [`evidence/README.md`](../../README.md), [`verification.md`](../../../../../specs/technical/verification.md) H1–H4 |

The two red product rows (`navigate` / #95, `kill-relaunch` / #96) are honest
observations owned by open epics and are **not** counted against this task.

## Playtesting

Not required. The deliverable is headless test infrastructure under
`game/test/integration/`; it changes no playable behavior, and the run above
*is* its headless exercise. Per [`playtest.md`](../../../../../specs/playtest/playtest.md)
§Gate the gate applies to deliverables that change playable behavior.

## Why there is no `manifest.md`

No Applies quality axis can be moved by this deliverable. The harness is
measurement infrastructure: it **observes** `frame-time`, `hitch-bound`,
`time-to-playable`, `transition-latency`, `response-delay`, `crash-free`, and
`resume-after-failure`; it cannot change any of them. [`run-quality-evaluators`](../../../../../.agents/skills/run-quality-evaluators/SKILL.md)
selects an axis only when the deliverable can change its outcome, and
[`docs/quality/evidence/README.md`](../../README.md) writes a folder only when
at least one axis is selected — and reserves `manifest.md` for that evaluator
record. The only qualitative axes (accessibility, localization) are not
delivered here. So this folder is a plain acceptance record, and its
`integration/` subtree is the harness output cited below.

Prior `issue-166` evaluator runs (`2026-11-02-deterministic`, `2026-11-02-verify-rerun`)
scored **product** axes against the harness; they remain valid product
observations and are not verdicts on #166.

## Artifacts cited by other issues

The product issues (#101, #110, #112) that were blocked on `no-invariant` for
I1, I2, I6–I10 can cite a run like this one for their axes. The harness run in
this folder is the `issue-166` deliverable's own output; a per-issue run is a
fresh invocation into that issue's run folder.
