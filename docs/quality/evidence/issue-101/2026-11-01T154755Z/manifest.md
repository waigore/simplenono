# Quality evaluator run — issue #101

- **Issue:** #101 Shell scene stub: CMP-shell is the first screen and holds a hardcoded puzzle ID
- **Mode:** `deterministic`
- **Deliverable commit:** `ea50de505894b6ce117b7d69c69e87dea1917438` (PR #136, open, not merged)
- **Runner:** `issue-workflow-verify-agent` (parallel id 1), 2026-11-01

## Results

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence |
|------|-----------|-------------|-----|--------|----------------|----------|
| `crash-free` | deterministic | The deliverable replaces `game/main.tscn` with `game/presentation/shell.tscn` — one `Control` that sets one `Label` text from a constant. Open, solve, reset, and back flows do not exist (AC 4 assigns the open leg and journey wiring to #112; real puzzle UI is #110), so invariant I9 (integration) has no flow to drive. A headless launch (`godot --headless --path game --quit-after 90`, exit 0) is a smoke observation only and does not exercise I9. | No crash across open, solve, reset, and back flows | blocked | `no-invariant` — I9's four flows are outside this deliverable's scope, so the observation it describes cannot be taken | `game/presentation/shell.gd`, `game/presentation/shell.tscn`, `specs/ux/journeys/play-puzzle.md` |
| `resume-after-failure` | deterministic | No attempt, no progress record, and no persistence path is touched: the diff adds no `game/play/` or `game/records/` code and the stub holds no marks or elapsed. Invariant I10 (kill-and-relaunch harness) cannot be driven. | After kill/crash mid-puzzle, next launch is gallery; marks and elapsed restore on reopen | blocked | `no-invariant` — I10 requires a mid-puzzle attempt and persisted marks/elapsed, neither of which exists in this deliverable | diff `origin/main...origin/task/101-shell-stub` (7 files, none under `game/play/` or `game/records/`) |
| `runtime-signals` | deterministic | Invariant I11 (smoke, "Debug build with S4") requires three signal groups — severity-tagged error/crash logs, frame/hitch samples, and story-ID telemetry events. The stub emits none of them: `shell.gd` contains no log call, no frame/hitch sampler, and no telemetry emit. S4 lists `CMP-shell` as the logger, but S4 is realized by `open`/`ready`/`mark`/`solved`/`pause`/`resume`/`leave`/`commit`/`reset` events, and none of those events exist at this scope. | Severity-tagged error/crash logs, frame/hitch samples, and story-ID telemetry events are present | blocked | `no-invariant` — the S4 event set I11 observes is not reachable from a stub that performs no attempt operation and navigates nowhere | `game/presentation/shell.gd` (no log/sample/telemetry call), `specs/technical/verification.md` S4, `specs/technical/verification/invariants.md` I11 |

Other Applies axes were not selected — their outcomes cannot move for this deliverable:

- `frame-time` (I1), `hitch-bound` (I2), `transition-latency` (I7), `response-delay` (I8) — the stub does no grid paint, no navigation, and no non-paint UI action, so I1/I2/I7/I8 have nothing to sample.
- `time-to-playable` (I6) — I6 measures cold launch to *interactive gallery*. The deliverable makes the shell stub the run entry and adds no gallery, so I6's endpoint does not exist yet.
- `save-survives` / `failed-write` (I4) — no persistence is touched.
- N/A axes in `specs/definition/quality.md` (accessibility, localization) are not scored.

## Coverage / cross-reference

- No cataloged assets are added or changed by #101: `game/assets/` and the asset catalog are untouched by PR #136. `review-asset` not applicable.
- `review-code` ran on the PR #136 diff (7 files, all implementation): **Pass**, no must-fix findings. See the verify comment on #101.
- Independent checks run on the PR head (`ea50de5`): headless launch exit 0; GUT 96/96 passed (2 new); Code lint / Unit tests / Coverage / Spec lint / PR hygiene all pass.

## Verdict

`Fail` — three Applies deterministic axes evaluated as blocked (`no-invariant`). Per
[`run-quality-evaluators`](../../../../../.agents/skills/run-quality-evaluators/SKILL.md), a blocked row fails the run, and
[`verify-project-issue`](../../../../../.agents/skills/verify-project-issue/SKILL.md) fails verification on it.
