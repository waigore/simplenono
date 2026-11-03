# Quality evaluator run — issue #499

- **Issue:** #499 Release export presets and asset manifest packaging for the five supported platforms (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `6d7286d` (PR #500, `task/499-release-export-presets`, the commit that carries all `game/` and `.github/` work). `game/` at the PR head `2e547f4` is identical — `git diff 6d7286d 2e547f4 -- game/` is empty; the later commit only rewords ADR-0008 and adds this record.
- **Evaluated:** 2026-11-04 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on macOS arm64
- **Observation source:** [`results.md`](results.md), from five sequential runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<scratch folder>`
  (`app-start`, `paint`, `navigate`, `ui-ack`, `solve-reset`) under an isolated `HOME` (fresh `user://`), plus the GUT suite
  (328/328) for the unit-level rows. The harness's `logs/`, `samples/`, and `results/` are gitignored, so this record keeps
  only the markdown.

Selected axes are the Applies deterministic axes this deliverable can move. `asset_resolver.gd` changes
`default_manifest_path()`, the read the shell performs at app start (`shell.gd` `_ready()`), so the launch path is
`time-to-playable` (I6). The change touches no paint, navigation, input, persistence, telemetry, or flow code, so the
remaining axes cannot move and are not selected.

No existing record covers `game/` at `6d7286d`: the nearest, #282 at `1b5dbc9`, diffs against this tree in
`game/presentation/asset_resolver.gd` (and the pack rows), so it does not reuse. This is a fresh run.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 263.7 ms; `flows_failed` empty, `crashed` false. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`results.md`](results.md) |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the `paint`/`navigate` rows are recorded for
  completeness only and are not claimed here.
- `transition-latency`, `response-delay` (I7, I8) — no navigation, screen, or input path changed.
- `crash-free` (I9) — no flow code changed; the five runs above completed with `flows_failed` empty.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed. The `kill-relaunch` protocol fails on
  `elapsed restored: false`; the same failure reproduces on `origin/main` at `6b06ddf` with this PR absent, so it is
  pre-existing and not this deliverable's. It is not selected here and is not charged to #499.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
