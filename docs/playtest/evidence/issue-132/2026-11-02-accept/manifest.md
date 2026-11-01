# Playtest evidence — issue #132, run `2026-11-02-accept`

- **Issue:** #132 Solve loop: get-set-ready, auto-cross (`CMP-rules` R3), ready edge and elapsed ticking
- **Build / session id:** `main@a0c2e39` (Godot 4.7.2.stable)
- **Coverage mode:** `full` ([`playtest.md`](../../../../../specs/playtest/playtest.md) Coverage)
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended dispatch
- **Level:** Design (`PTD-ready-and-marks`)

## Results

| ID | Result | Note |
|----|--------|------|
| S1 | pass (seam) | A mark while `marks-allowed` is false changes nothing. `DBG.3` does not exist, so the beat is entered through `Attempt.open` / `end_get_set_ready`. |
| S2 | pass (seam) | After Ready, fill → clear → cross apply. `UI-puzzle.C3`–`C5`/`C2` and `DBG.2` do not exist; driven on `Attempt.mark`. |
| S3 | pass (seam) | A wrong fill neither solves nor enters a fail state; the attempt stays in progress (`PS1.4`, #109). |
| S4 | pass (seam) | Pause freezes elapsed and blocks marks; resume restores both. `IN.pause` / `UI-puzzle.C6` do not exist. |
| P1 | pass | Marks do not stick during get-set-ready; fill / clear / cross work once Ready. |
| P2 | pass | Empty-clue lines auto-cross still-clear cells at beat end; in progress when a cross occurred. Judged, not N/A. |
| P3 | pass | Wrong fills do not solve or fail; pause freezes elapsed and blocks marks. |
| F1, F2 | not observed | — |

`PTD-ready-and-marks` is the protocol for this issue. `P2` is judged rather than N/A because a
synthetic all-empty-clue definition guarantees empty lines; `evidence.md` allows N/A only when the
fixture has none.

**Screenshots:** none. `PTD-ready-and-marks` uses the default evidence rules and does not say
none, so [`evidence.md`](../../../../../specs/playtest/evidence.md) requires an image of each judged
pass state from a **graphical** re-run of this same build. No such image exists, and this build
cannot produce one: `game/presentation/shell.tscn` draws two labels and no grid, and no `DBG.*` /
`TEL.*` seam is built. Per `evidence.md` the omission is **not** a protocol fail and does not file
a defect.

## Paths

| Artifact | Path |
|----------|------|
| This manifest | `docs/playtest/evidence/issue-132/2026-11-02-accept/manifest.md` |
| Notes | [`notes.md`](notes.md) |
| Shipped suite log | [`logs/gut-full-suite.log`](logs/gut-full-suite.log) |
| Probe log | [`logs/probe-accept-132.log`](logs/probe-accept-132.log) |
| Screenshots | waiting on a graphical run of `main@a0c2e39` |

## Logs

`logs/gut-full-suite.log` — the `Unit tests` command on a clean worktree of `main@a0c2e39`: exit
0, 8 scripts, **123/123**.

`logs/probe-accept-132.log` — a scratch GUT probe written outside the repo (not committed) driving
the real `Attempt` and `Rules` over synthetic definitions: exit 0, **8/8**, 41 asserts. It covers
`CTR-rules` O3, the ready edge and E3 payload, `SEQ-open` B1 before and during a running beat, B3,
and `CTR-attempt` G1.
