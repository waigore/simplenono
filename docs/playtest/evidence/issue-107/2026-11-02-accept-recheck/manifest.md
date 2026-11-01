# Playtest run — issue #107 (re-check)

- **Issue:** #107 Clue line derivation (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-02-accept-recheck`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-02
- **Build / session id:** `main@37ef101`. No `TEL.3` session id exists — telemetry is
  unimplemented, and no first-party script emits `TEL.*` on this build.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)

## Scope

Re-check of [`2026-11-01-accept`](../2026-11-01-accept/manifest.md), which judged `E-clue`
and its in-scope protocol clauses pass at the delivered layer and held the issue only for
graphical screenshots.

This run re-judges on a build that has moved since that run and since
[`2026-11-01-accept-recheck`](../2026-11-01-accept-recheck/manifest.md): `CMP-rules` (#108,
`17cd68d`) now **consumes** `ClueLines`, and the app's first screen is the `CMP-shell` text
stub (#136, `007140d`) instead of a bare `Node`. The question is whether the mapper still
satisfies its criteria inside that consumer and whether a screenshot is now possible.

The deliverable itself is unchanged: `git diff ed9e33b 37ef101 -- game/play/clue_line.gd
game/play/clue_lines.gd game/play/clue_lines_result.gd game/test/test_clue_lines.gd
game/test/fixtures/teapot.json` is empty. `git diff ed9e33b 37ef101 -- specs/playtest` is
also empty, so the protocols this issue is judged against did not move.

Protocols for `E-clue`:
[`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md),
[`PTD-crosses-and-fills`](../../../../../specs/playtest/design/crosses-and-fills.md).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `E-clue` | pass at the delivered layer | criteria 1–5 re-affirmed; now exercised through its `CMP-rules` consumer |
| `E-clue` / `PTD-ready-and-marks` P2 (empty-clue auto-cross) | N/A at this layer | auto-cross is `CMP-rules` R3, still unmerged (#132); the fixture does exercise the premise (7 empty rows, 4 empty columns) |
| `E-clue` / clauses needing solve state, the puzzle screen, or pause | out of scope | #110, #112, #132; no clause this layer can decide was observed to fail |
| Graphical re-run | **waiting** | the only scene is a text stub; no board, clue bars, `DBG.*`, or `TEL.*` exist to capture |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes (what changed, judgement, blocker) | [`notes.md`](notes.md) | present |
| Criteria and fixture integrity | [`criteria.md`](criteria.md) | present |
| Falsification | [`falsification.md`](falsification.md) | present |
| Log — full suite at `37ef101` | [`logs/gut-recheck.log`](logs/gut-recheck.log) | present (6 scripts, 96/96, exit 0) |
| Log — falsification mutation, then reverted | [`logs/gut-falsification-columns.log`](logs/gut-falsification-columns.log) | present (11 failing, exit 1) |
| Log — fixture integrity check | [`logs/fixture-check.log`](logs/fixture-check.log) | present |
| Log — fresh-worktree import | [`logs/godot-import.log`](logs/godot-import.log) | present |
| Prior run, step-level judgement | [`../2026-11-01-accept/`](../2026-11-01-accept/manifest.md) | present, unchanged |
| Screenshot — `PTD-ready-and-marks` judged state | `screenshots/ready-and-marks.png` | **waiting on a graphical re-run of the same build** |
| Screenshot — `PTD-crosses-and-fills` judged state | `screenshots/crosses-and-fills.png` | **waiting on a graphical re-run of the same build** |

Per [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md), omitting
screenshots in a headless run is marked waiting here and is not a protocol fail; the issue
stays `status:pending-acceptance`.
