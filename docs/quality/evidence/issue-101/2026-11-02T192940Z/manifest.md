# Quality evaluator run — issue #101

- **Issue:** #101 Shell scene stub: CMP-shell is the first screen and holds a hardcoded puzzle ID
- **Mode:** `deterministic`
- **Deliverable commit:** `fdcb298` (`origin/main`; the #101 code landed with PR #136 `007140d` and is unchanged since the `ea50de5` run of 2026-11-01)
- **Evaluated:** 2026-11-02 by `issue-workflow-implement-agent` (parallel id 1), Godot 4.7.2 on macOS, headless
- **Observation source:** `integration/results.md` in this folder, from six sequential runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=docs/quality/evidence/issue-101/2026-11-02T192940Z`
  (`app-start` 0, `paint` 0, `navigate` 1, `ui-ack` 0, `solve-reset` 0, `kill-relaunch` 1)

## Why this run exists

The 2026-11-01 run (`../2026-11-01T154755Z/`) blocked `crash-free`, `resume-after-failure`, and `runtime-signals` with reason
`no-invariant`. That was true when it was written: the S1–S5 seams and the integration harness did not exist yet. The harness
landed with #166, and #163 merged the S4 telemetry sink whose severity-log quarter was the last outstanding piece. This run
re-evaluates against that harness on today's `main`. The product code under test is byte-identical to `ea50de5`; only the
observation method changed.

## Selection

Selected: the Applies deterministic axes whose citing invariant the harness can now observe for this deliverable.

- The stub is the run entry, so launch and quit (`app-start`) reach it. I9's open/solve/reset/back flows run in the harness
  through #110/#112's puzzle screen, which sits behind this stub — the run says `crash-free` holds.
- I10 (`kill-relaunch`) and I11 (S4) now run and are observed directly.

Not selected — the stub does no paint, navigation, non-paint UI, or persistence of its own; those are #110/#112/#94–#96 rows:

- `frame-time` (I1), `hitch-bound` (I2) — the stub draws one `Label`; no surface of its own to sample.
- `transition-latency` (I7), `response-delay` (I8) — navigation and settings intents belong to #94/#95/#112.
- `time-to-playable` (I6) — measures cold launch to the *gallery*, which is #94; the stub's home view is a stand-in.
- `save-survives` / `failed-write` (I4) — the stub writes no committed progress.
- N/A accessibility and localization axes are not scored.

## Results

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `crash-free` | deterministic | I9: open, solve, reset, and back all ran (`paint`, `navigate`, `ui-ack`, `solve-reset`), with no failed flow and no crashed run. `navigate` and `kill-relaunch` exit 1 on their own axes (I7, I10), not on I9. | No crash across open, solve, reset, and back flows | pass | — | `integration/results.md` |
| `resume-after-failure` | deterministic | I10: relaunch entry is the shell home (gallery stand-in until #94) and the puzzle reopens, but `marks restored: false` and `elapsed restored: false`. | After kill/crash mid-puzzle, next launch is gallery; marks and elapsed restore on reopen | fail | — | `integration/results/kill-relaunch.json`, `integration/logs/relaunch-verify.json` |
| `runtime-signals` | deterministic | I11: the S4 log carries severity-tagged `SEV` lines (`session-start` / `session-end` plus engine error lines) and story-ID `TEL` events (`story=-`, since no story id was supplied to this run), and `paint` wrote 203 per-frame samples plus a hits file. | Severity-tagged error/crash logs, frame/hitch samples, and story-ID telemetry events are present | pass | — | `integration/logs/*-ui-ack.log`, `integration/samples/paint-samples.ndjson` |

## Verdict

`Fail` — `resume-after-failure` (I10) fails. The cause is not this deliverable: the stub navigates nowhere and persists
nothing (AC 2/3), and mark/elapsed restore is #96's work. The same I10 row fails on `main` for every issue, as recorded in
`docs/quality/evidence/issue-110/2026-11-01T190448Z` and `issue-166/2026-11-02-acceptance`. Per
[`run-quality-evaluators`](../../../../../.agents/skills/run-quality-evaluators/SKILL.md), any failing row fails the run and
[`verify-project-issue`](../../../../../.agents/skills/verify-project-issue/SKILL.md) fails verification on it.

## Cross-reference

- `review-code` on PR #136 (`007140d`): **Pass**, no must-fix findings (recorded in the 2026-11-01 verify comment).
- Independent checks today on `origin/main` (`fdcb298`): GUT 142/142 pass; six harness protocols run headless as listed above.
- No cataloged assets added or changed; `review-asset` not applicable.
