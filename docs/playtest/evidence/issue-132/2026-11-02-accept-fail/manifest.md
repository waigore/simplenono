# Playtest evidence — issue #132, run `2026-11-02-accept-fail`

- **Issue:** #132 Solve loop: get-set-ready, auto-cross (`CMP-rules` R3), ready edge and elapsed ticking
- **Build / session id:** `main@a8b54dc` (Godot 4.7.2.stable)
- **Coverage mode:** `full` ([`playtest.md`](../../../../../specs/playtest/playtest.md) Coverage)
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended dispatch
- **Level:** Design (`PTD-ready-and-marks`)

## Results

| ID | Result | Note |
|----|--------|------|
| S1 | **fail** | Fresh puzzle: a mark during get-set-ready changes nothing (pass). **A reopened puzzle with a persisted in-progress record accepts marks during get-set-ready** (fail, see `notes.md`). |
| S2 | pass (seam) | After Ready, fill → clear → cross apply. `UI-puzzle.C3`–`C5` / `C2` do not exist; driven on `Attempt.mark`. |
| S3 | pass (seam) | A wrong fill neither solves nor fails; the attempt stays in progress (`PS1.4`, #109). |
| S4 | pass (seam) | Pause freezes elapsed and blocks marks; resume restores both. `IN.pause` / `UI-puzzle.C6` do not exist. |
| P1 | **fail** | Marks stick during get-set-ready on a restored in-progress attempt. The after-Ready transitions pass. |
| P2 | pass | Empty-clue lines auto-cross still-clear cells at beat end; in progress when a cross occurred. |
| P3 | pass | Wrong fills do not solve or fail; pause freezes elapsed and blocks marks. |
| F1 | **triggered** | "Marks apply during get-set-ready" — yes, on the reopen path. Blocks acceptance. |
| F2 | not observed | — |

**Screenshots:** none. This is a headless acceptance run; `evidence.md` requires a graphical
re-run's image for each judged pass state, and the build has no debug surface (`verification.md`
H1). The fail recorded here does not depend on a screenshot: it is a model-level behaviour
falsified by the probe and visible only because the #110 screen renders S2 with marks enabled.

## Paths

| Artifact | Path |
|----------|------|
| This manifest | `docs/playtest/evidence/issue-132/2026-11-02-accept-fail/manifest.md` |
| Notes | [`notes.md`](notes.md) |
| Shipped suite log | [`logs/gut-full-suite.log`](logs/gut-full-suite.log) |
| Probe log | [`logs/probe-accept-132.log`](logs/probe-accept-132.log) |
| Probe source (not shipped) | [`probe/test_accept_132_probe.gd`](probe/test_accept_132_probe.gd) |
| Screenshots | waiting on a graphical run of `main@a8b54dc` |

## Logs

`logs/gut-full-suite.log` — the `Unit tests` command on a clean detached worktree of
`main@a8b54dc`: exit 0, 9 scripts, **132/132**, 29584 asserts.

`logs/probe-accept-132.log` — the run's independent probe, written into `game/test/` for the run
and removed after it: 9 tests, **7 passing / 2 failing**, 543/551 asserts, exit 1. Both failures
are the reopen path (`test_open_in_progress_record_keeps_marks_blocked_until_beat_end`,
`test_shipped_pack_resume_keeps_marks_blocked`).
