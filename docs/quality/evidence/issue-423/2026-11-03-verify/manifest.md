# Quality evaluator run — issue #423

- **Issue:** #423 Gallery Confirm reset emits no telemetry event (TEL.1 / S4) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `1161953` (`main` squash of PR #431). The measured tree is `main` at `278717c`; `git diff 1161953 278717c -- game/` is empty, so the deliverable's `game/` is the tree observed here.
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=solve-reset --run-dir=<this folder> --story-ids=US1.1`,
  plus [`logs/gut-suite.log`](logs/gut-suite.log) for the unit-level rows. The run used a fresh `user://` document: a
  leftover in-progress `pack-000` record makes the protocol's solve leg fail on already-marked cells, which is the
  harness's documented dirty-record behaviour.

Two Applies deterministic axes can move, both because this deliverable adds telemetry to an existing user path:

- `runtime-signals` (I11) — the `reset` event is new on the gallery Confirm path. I11 is a product outcome, so the
  observation is a product run, not a before/after diff of `integration/`. The `solve-reset` log now carries one
  `reset` line keyed to a story id.
- `crash-free` (I9) — the reset flow gains a call on the shell's success path; `solve-reset` drives open, solve,
  reset, and back in one run.

No existing record covered `game/` at `1161953` (`git diff <recorded> 1161953 -- game/` is non-empty for every earlier
`docs/quality/evidence/*` record; the newest, #269, records `1e75c62`), so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `runtime-signals` | deterministic | I11 on a debug build with S4, `solve-reset` run: two severity-tagged `SEV` lines (`session-start`, `session-end`), 71 story-keyed `TEL` events with `story=US1.1`, and exactly one `TEL event=reset … session=session-1793669216 build=4.7.2-stable (official) story=US1.1 outcome=pass` on the reset flow. Unit level: `test_a_gallery_confirm_records_exactly_one_reset_event` asserts `TEL.1`–`TEL.5` on a real Confirm. | Local severity-tagged error/crash logs; frame/hitch timing samples; playtest telemetry events keyed to story IDs | pass | — | `integration/logs/harness-1793669216-solve-reset.log`; `logs/gut-suite.log` |
| `crash-free` | deterministic | I9: `solve-reset` recorded the flows `back`, `open`, `reset`, `solve` with none failed and `crashed: false`; the shell's Confirm path is the reset flow under test. | No crash across open, solve, reset, and back | pass | — | `integration/results.md`; `integration/results/solve-reset.json` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint, grid, or navigation code changed. The deliverable adds one call
  after the reset write, on the gallery's Confirm path, which neither sampling window drives.
- `time-to-playable` (I6) — no launch or pack-load path changed.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or acknowledgement path changed.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed; the reset write is the existing O7.
- `save-survives`, `failed-write` (I4) — no save schema, commit, or write seam changed. O7 still runs before the event.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.

## Verdict

`Pass` — both selected Applies deterministic axes are observed and within their bar; no row is `fail` or `blocked`.
