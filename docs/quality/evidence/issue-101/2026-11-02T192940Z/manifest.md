# Quality evaluator run — issue #101

- **Issue:** #101 Shell scene stub: CMP-shell is the first screen and holds a hardcoded puzzle ID
- **Mode:** `deterministic`
- **Deliverable commit:** `fdcb298` (`origin/main`; the #101 code landed with PR #136 `007140d` and is unchanged since `ea50de5`)
- **Evaluated:** 2026-11-02 by `issue-workflow-implement-agent` (parallel id 1), Godot 4.7.2 on macOS, headless
- **Observation source:** `integration/results.md` in this folder — six harness protocols; command, exit codes, selection, and
  why the 2026-11-01 run's `blocked` rows no longer apply: [details.md](details.md)

## Results

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `crash-free` | deterministic | I9: open, solve, reset, and back all ran (`paint`, `navigate`, `ui-ack`, `solve-reset`), with no failed flow and no crashed run. The `navigate` and `kill-relaunch` exits are their own axes (I7, I10), not I9. | No crash across open, solve, reset, and back flows | pass | — | `integration/results.md` |
| `resume-after-failure` | deterministic | I10: relaunch entry is the shell home (gallery stand-in until #94) and the puzzle reopens, but `marks restored: false` and `elapsed restored: false`. | After kill/crash mid-puzzle, next launch is gallery; marks and elapsed restore on reopen | fail | — | `integration/results/kill-relaunch.json`, `integration/logs/relaunch-verify.json` |
| `runtime-signals` | deterministic | I11: the S4 log carries severity-tagged `SEV` lines (`session-start` / `session-end` plus engine error lines) and story-ID `TEL` events (`story=-`; no story id was supplied to this run), and `paint` wrote 203 per-frame samples plus a hits file. | Severity-tagged error/crash logs, frame/hitch samples, and story-ID telemetry events are present | pass | — | `integration/logs/*-ui-ack.log`, `integration/samples/paint-samples.ndjson` |

## Verdict

`Fail` — `resume-after-failure` (I10) fails. The cause is not this deliverable: the stub navigates nowhere and persists
nothing (AC 2/3), and mark/elapsed restore is #96's work. The same I10 row fails on `main` for every issue, as recorded in
`docs/quality/evidence/issue-110/2026-11-01T190448Z` and `issue-166/2026-11-02-acceptance`. Per
[`run-quality-evaluators`](../../../../../.agents/skills/run-quality-evaluators/SKILL.md), any failing row fails the run and
[`verify-project-issue`](../../../../../.agents/skills/verify-project-issue/SKILL.md) fails verification on it.

Cross-reference checks (code review, GUT, asset applicability): [details.md](details.md).
