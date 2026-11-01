# Playtest run — issue #106 (re-check)

- **Issue:** #106 Cell mark semantics (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-01-accept-recheck`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-01
- **Build / session id:** `main@5844364` (evidence commit on top of `eea5f9d`, the squash of PR #118). No `TEL.3` session id exists — telemetry is unimplemented (see [`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md)).
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)

## Scope

Re-check of the prior acceptance run [`2026-11-01-accept`](../2026-11-01-accept/manifest.md), which judged both in-scope protocols pass at the delivered layer and is held only for graphical screenshots. This run re-confirms that the build under judgement is unchanged and re-runs the test surface; it does not re-judge the protocols' step detail.

`git diff --stat eea5f9d 5844364 -- game` is empty, so the judged build is byte-identical to the one the prior run tested.

Protocols for `E-cell`: [`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md), [`PTD-crosses-and-fills`](../../../../../specs/playtest/design/crosses-and-fills.md). Step-level judgement and `SIT.3` dumps: [`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `E-cell` / `PTD-ready-and-marks` | pass at the delivered layer | carried forward unchanged; same build |
| `E-cell` / `PTD-crosses-and-fills` | pass at the delivered layer | carried forward unchanged; same build |
| Graphical re-run | **waiting** | `game/main.tscn` is still one bare `Node`; no board or debug surface exists to screenshot |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes (step-level judgement) | [`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md) | present, unchanged |
| Prep and seam method | [`../2026-11-01-accept/setup-and-seam.md`](../2026-11-01-accept/setup-and-seam.md) | present, unchanged |
| Logs | [`../2026-11-01-accept/logs/`](../2026-11-01-accept/logs/) | present, unchanged |
| Log — full suite re-run | `logs/gut-recheck.log` | present |
| Screenshot — `PTD-ready-and-marks` judged state | `screenshots/ready-and-marks.png` | **waiting on a graphical re-run of the same build** |
| Screenshot — `PTD-crosses-and-fills` judged state | `screenshots/crosses-and-fills.png` | **waiting on a graphical re-run of the same build** |

Per [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md), the omitted screenshots are marked waiting here and are not a protocol fail; the issue stays `status:pending-acceptance`.
