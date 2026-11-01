# Playtest run — issue #107 (re-check 2)

- **Issue:** #107 Clue line derivation (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-02-accept-recheck-2`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-02
- **Build / session id:** `main@22c88c2`. No `TEL.3` session id exists — telemetry is
  unimplemented and no first-party script emits `TEL.*` on this build.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)

## Scope

Re-check after [`2026-11-02-accept-recheck`](../2026-11-02-accept-recheck/manifest.md).
Two commits landed on this issue's ground since that run:

- **#132 (`dd0948b`)** builds the open/ready edge and the empty-line auto-cross
  (`CMP-rules` R3, `CTR-attempt` O1/O3). `PTD-ready-and-marks` P2 was recorded **N/A**
  in every prior run because auto-cross did not exist. It exists now.
- **#141 (`5e8f226`)** approves gallery mockups — docs only.

The deliverable is unchanged: `git diff ed9e33b 22c88c2 -- game/play/clue_line*.gd
game/test/test_clue_lines.gd game/test/fixtures/teapot.json` is empty. `git diff ed9e33b
22c88c2 -- specs/playtest` is also empty.

Protocols for `E-clue`:
[`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md),
[`PTD-crosses-and-fills`](../../../../../specs/playtest/design/crosses-and-fills.md).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `E-clue` | pass at the delivered layer | criteria 1–5 re-affirmed; 17 clue tests in the suite |
| `E-clue` / `PTD-ready-and-marks` P2 (empty-clue auto-cross) | **pass at the delivered layer (new)** | empty rows `[0–3, 12–14]` and columns `[0–1, 13–14]` come from the mapper under acceptance; the ready edge crosses exactly their 137 still-clear cells and the attempt turns in progress |
| `PTD-crosses-and-fills` P1–P2 | out of scope | needs `GS.is-solved` and the result screen (#109/#110), not the mapper |
| `PTD-ready-and-marks` P1/P3 steps needing `DBG.2`/`DBG.3`, `UI-puzzle.C2`–`C6`, pause | out of scope | #110/#111/#112; no clause this layer can decide failed |
| Graphical re-run | **waiting** | no first-party script draws; the only scene is the `CMP-shell` text stub |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes | [`notes.md`](notes.md) | present |
| Criteria and fixture integrity | [`criteria.md`](criteria.md) | present |
| Falsification | [`falsification.md`](falsification.md) | present |
| Probe source (run once, then removed from `game/test/`) | [`probe-ready-auto-cross.gd`](probe-ready-auto-cross.gd) | present |
| Log — full suite at `22c88c2` | [`logs/gut-accept.log`](logs/gut-accept.log) | present (7 scripts, 113/113, exit 0) |
| Log — empty-clue auto-cross probe | [`logs/probe-ready-auto-cross.log`](logs/probe-ready-auto-cross.log) | present (2/2, 233 asserts, exit 0) |
| Log — falsification mutation, then reverted | [`logs/gut-falsification-columns.log`](logs/gut-falsification-columns.log) | present (13 failing, exit 1) |
| Log — fixture integrity | [`logs/fixture-check.log`](logs/fixture-check.log) | present |
| Log — fresh-worktree import | [`logs/godot-import.log`](logs/godot-import.log) | present |
| Prior runs | [`../2026-11-01-accept/`](../2026-11-01-accept/manifest.md), [`../2026-11-01-accept-recheck/`](../2026-11-01-accept-recheck/manifest.md), [`../2026-11-02-accept-recheck/`](../2026-11-02-accept-recheck/manifest.md) | present, unchanged |
| Screenshot — `PTD-ready-and-marks` judged state | `screenshots/ready-and-marks.png` | **waiting on a graphical re-run of the same build** |
| Screenshot — `PTD-crosses-and-fills` judged state | `screenshots/crosses-and-fills.png` | **waiting on a graphical re-run of the same build** |

Per [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md), omitting
screenshots in a headless run is marked waiting here and is not a protocol fail; the issue
stays `status:pending-acceptance`.
