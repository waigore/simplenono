# Quality evaluator run — issue #344

- **Issue:** #344 UI font kind: catalogue, review, and resolve the family by asset ID (AK-fonts V1) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `90a76bd` (`main` at verification; the implementation run recorded no new commit — the artifacts landed in PRs #227 and #285, and `game/` here is the tree measured)
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<this folder>`

Only `time-to-playable` is selected. This deliverable adds no runtime code; it confirms the one `fonts/outfit` catalog
entry, its generated manifest row, and the by-asset-ID resolver seam (#191) plus the theme's `FontVariation` (`tnum`)
wrap (#224/#285). The font file and its `.import` sidecar are loaded on the shell's start
path, so launch-to-interactive-gallery is the one Applies deterministic axis this deliverable can reach.

No existing record covers `game/` at `90a76bd`: no `Deliverable commit` field across
`docs/quality/evidence/*/*/manifest.md` resolves to a commit whose `git diff <commit> HEAD -- game/` is empty, so this is a
fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 1947.0 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793667320-app-start.log` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the `app-start` run above passed all five steps.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## Run limit

The 1947.0 ms launch figure is a cold headless launch on this Linux runner with no GPU; it is well inside the 3 s bar but
is not a mid-range-phone measurement. The other flows (`paint`, `navigate`, `ui-ack`, `solve-reset`, `kill-relaunch`)
were not run because this deliverable reaches none of their axes.
