# Playtest run — issue #106

- **Issue:** #106 Cell mark semantics (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-01-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-01
- **Build / session id:** `main@eea5f9d` (squash merge of PR #118: "Cell mark semantics (#106)"). No `TEL.3` session id exists yet — telemetry is not implemented (`runtime-signals` is unrealized; see notes).
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)

## Scope

Coverage set (`full`, every design story ∩ issue playable IDs) ∩ the story the deliverable can affect.

| Story | Mapped to issue | In scope | Why |
|-------|-----------------|----------|-----|
| `E-cell` | #106 ([`story-rows.md`](../../../../../specs/playtest/story-rows.md)) | yes | The deliverable is cell mark semantics |
| `L-solve`, `GS`, `E-clue`, `END` | #107, #108, #111 | no | Solve/line status, game state, and mark input are other tasks; the grid value object does not realize them yet |

Protocols selected for `E-cell`: [`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md) (cites `E-cell`) and [`PTD-crosses-and-fills`](../../../../../specs/playtest/design/crosses-and-fills.md) (cites `E-cell`).

## Results

| Story or protocol | Outcome | Judged against |
|-------------------|---------|----------------|
| `E-cell` / `PTD-ready-and-marks` | pass at the delivered layer (P1, P2 in seam form); P3–P4 not reachable | `specs/design/stories/entities/cell.md` PS1.1–PS1.5; `specs/design/entities/cell.md` S1–S3, I1, I4, I5 |
| `E-cell` / `PTD-crosses-and-fills` | pass at the delivered layer (P1, P2 in seam form) | `specs/design/entities/cell.md` S2, S3, I2, I3 |
| Graphical re-run | **waiting** | `specs/playtest/evidence.md` — screenshots required before acceptance |

Prep and judgement boundary: [`setup-and-seam.md`](setup-and-seam.md). Details and per-step observations: [`notes.md`](notes.md).

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Prep and seam method | [`setup-and-seam.md`](setup-and-seam.md) | present |
| Notes | [`notes.md`](notes.md) | present |
| Log — `PTD-ready-and-marks` | `logs/gut-ready-and-marks.log` | present |
| Log — `PTD-crosses-and-fills` | `logs/gut-crosses-and-fills.log` | present |
| Screenshot — `PTD-ready-and-marks` judged state | `screenshots/ready-and-marks.png` | **waiting on a graphical re-run of the same build** |
| Screenshot — `PTD-crosses-and-fills` judged state | `screenshots/crosses-and-fills.png` | **waiting on a graphical re-run of the same build** |

`SIT.3` state dumps live inline in [`notes.md`](notes.md) (seam output); `SIT.1`/`SIT.2` are not cited by either protocol.

Per [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md), a headless run may judge and record pass/fail, notes, and logs, and marks screenshots as waiting. Absence of screenshots is not a protocol fail and does not file a defect; the issue stays `status:pending-acceptance` until a graphical run of `main@eea5f9d` writes them here.
