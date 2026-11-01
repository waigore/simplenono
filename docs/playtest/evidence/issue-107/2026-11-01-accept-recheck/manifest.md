# Playtest run — issue #107 (re-check)

- **Issue:** #107 Clue line derivation (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-01-accept-recheck`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-01
- **Build / session id:** `main@1e90d76` (evidence commit on top of `ed9e33b`, the squash of PR #121). No `TEL.3` session id exists — telemetry is unimplemented (see [`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md)).
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)

## Scope

Re-check of the prior acceptance run [`2026-11-01-accept`](../2026-11-01-accept/manifest.md), which judged `E-clue` and its in-scope protocol clause pass at the delivered layer and was held only for graphical screenshots. This run re-confirms that the judged build is unchanged and re-runs the test surface; it does not re-judge the step detail.

`git diff --stat ed9e33b 1e90d76 -- game` is empty, so the judged build is byte-identical to the one the prior run tested.

Protocols for `E-clue`: [`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md), [`PTD-crosses-and-fills`](../../../../../specs/playtest/design/crosses-and-fills.md). Step-level judgement and the N/A marks for lines this deliverable cannot decide: [`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `E-clue` | pass at the delivered layer | carried forward unchanged; same build |
| `E-clue` / `PTD-ready-and-marks` P2 (empty-clue auto-cross) | N/A at this layer | `CMP-rules` R3 (#108); carried forward |
| `E-clue` / protocol clauses needing solve state, the puzzle screen, or pause | out of scope | #108, #110, #111; carried forward |
| Graphical re-run | **waiting** | `game/main.tscn` is still one bare `Node`; no clue-drawing scene or debug surface exists to screenshot |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes (step-level judgement) | [`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md) | present, unchanged |
| Prior manifest | [`../2026-11-01-accept/manifest.md`](../2026-11-01-accept/manifest.md) | present, unchanged |
| Logs | [`../2026-11-01-accept/logs/`](../2026-11-01-accept/logs/) | present, unchanged |
| Log — full suite re-run | `logs/gut-recheck.log` | present |
| Log — falsification mutation | `logs/gut-falsification-mutation.log` | present (run here, then reverted) |
| Screenshot — `PTD-ready-and-marks` judged state | `screenshots/ready-and-marks.png` | **waiting on a graphical re-run of the same build** |
| Screenshot — `PTD-crosses-and-fills` judged state | `screenshots/crosses-and-fills.png` | **waiting on a graphical re-run of the same build** |

Per [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md), the omitted screenshots are marked waiting here and are not a protocol fail; the issue stays `status:pending-acceptance`.
