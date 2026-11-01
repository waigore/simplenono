# Playtest evidence — issue #132, run `2026-11-02-accept`

- **Issue:** #132 Solve loop: get-set-ready, auto-cross (`CMP-rules` R3), ready edge and elapsed ticking
- **Build / session id:** `main@a0c2e39` (Godot 4.7.2.stable) — the tree the judgement ran on
- **Coverage mode:** `full` ([`playtest.md`](../../../../specs/playtest/playtest.md) Coverage)
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended dispatch
- **Level:** Design (`PTD-ready-and-marks`)

## Results

| ID | Result | Note |
|----|--------|------|
| `PTD-ready-and-marks` S1 | pass (headless, at the seam) | Get-set-ready: a mark while `marks-allowed` is false changes nothing. `DBG.3`/gallery entry does not exist, so the beat is entered through `Attempt.open` / `end_get_set_ready` rather than the Debug UI. |
| `PTD-ready-and-marks` S2 | pass (headless, at the seam) | After Ready, fill → clear → cross transitions apply on the grid. `UI-puzzle.C3`–`C5`/`C2` and `DBG.2` inspection do not exist; driven on `Attempt.mark` / `AttemptState`. |
| `PTD-ready-and-marks` S3 | pass (headless, at the seam) | A wrong fill neither solves nor enters a fail state; the attempt stays in progress (`PS1.4`, #109). |
| `PTD-ready-and-marks` S4 | pass (headless, at the seam) | Pause freezes elapsed and blocks player marks; resume restores both. `IN.pause` / `UI-puzzle.C6` do not exist; driven on `AttemptState.pause()` / `resume()`. |
| `PTD-ready-and-marks` P1 | pass | Marks do not stick during get-set-ready; fill / clear / cross work once Ready. |
| `PTD-ready-and-marks` P2 | pass | Empty-clue lines auto-cross their still-clear cells at beat end; the attempt becomes in progress when a cross occurred. **Judged, not N/A** — the synthetic all-empty-clue definition guarantees empty lines. |
| `PTD-ready-and-marks` P3 | pass | Wrong fills do not solve or fail; pause freezes elapsed and blocks marks. |
| `PTD-ready-and-marks` F1 | not observed | — |
| `PTD-ready-and-marks` F2 | not observed | — |

**Screenshots:** none. `PTD-ready-and-marks` Evidence says "Default evidence rules" and does not
say none, so [`evidence.md`](../../../../specs/playtest/evidence.md) requires ≥1 image of each
judged pass state from a **graphical** re-run of this same build. No such image exists anywhere in
the repo, and the build cannot produce one: `game/presentation/shell.tscn` is a title screen with
two labels and no grid, and no `DBG.*` / `TEL.*` seam is built (search of `game/` returns nothing).
Per `evidence.md` "Headless run", the omission is **not** a protocol fail and does not file a
defect.

## Paths

| Artifact | Path |
|----------|------|
| This manifest | `docs/playtest/evidence/issue-132/2026-11-02-accept/manifest.md` |
| Notes | [`notes.md`](notes.md) |
| Shipped suite log | [`logs/gut-full-suite.log`](logs/gut-full-suite.log) |
| Independent probe log | [`logs/probe-accept-132.log`](logs/probe-accept-132.log) |
| Screenshots (pass states) | waiting on a graphical run of `main@a0c2e39` |

## Logs

- `logs/gut-full-suite.log` — `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit`
  on a clean worktree of `main@a0c2e39`: exit 0, 8 scripts, **123/123** passing.
- `logs/probe-accept-132.log` — a scratch GUT probe written outside the repo (not committed) that
  drives the real `Attempt` + real `Rules` over synthetic definitions: exit 0, **8/8** passing,
  41 asserts. It covers `CTR-rules` O3 (CMP-rules R3), the ready edge and E3 payload, `SEQ-open`
  B1 (before and during a running beat), `SEQ-open` B3, and `CTR-attempt` G1.
