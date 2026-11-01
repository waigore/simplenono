# Playtest run — issue #105 (acceptance)

- **Issue:** #105 Pack data & loader per ADR-0004 (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-01-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1, dispatched worktree), 2026-11-01
- **Build / session id:** `main@dfd3ca4`. No `TEL.3` session id exists — telemetry is unimplemented.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)

## Scope

Story `E-puzzle` ([`story-rows.md`](../../../../../specs/playtest/story-rows.md) owner #105) intersected with
the deliverable, per [`procedures.md`](../../../../../specs/playtest/procedures.md). The only shipped protocol
that cites `E-puzzle` is `PTD-ready-and-marks`. #105 delivers pack data and the O8/O3 load path, so the
reachable part is `E-puzzle` PS1.1 (size, clues, fills, and identity come from that pack entry).

`PS1.2`–`PS1.5` need the attempt, the solve loop, `END`, and the gallery (#108, #109, #110, #111), and the
remaining protocols cite only undelivered stories.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `E-puzzle` / `PTD-ready-and-marks` — PS1.1 pack properties | pass at the delivered layer | [`notes.md`](notes.md) |
| `E-puzzle` — PS1.2, PS1.2b, PS1.3, PS1.4, PS1.4b, PS1.4c, PS1.5 | not judged — outside this deliverable | owned by #108/#109/#110/#111; see [`playtest-gap.md`](playtest-gap.md) |
| `PTD-crosses-and-fills` | not run — not in `E-puzzle` scope | owned by #106/#108 |
| `PTD-solve-and-pb`, `PTD-pack-finished` | not run — not in `E-puzzle` scope | owned by #108/#109 |
| `PTU-*` journeys | not run — no main-tree UI | #110/#111/#112 |
| Graphical re-run | **waiting** | nothing on this build draws a board |

The protocol and its screenshot cannot exist on this build; this is recorded as
[`playtest-gap.md`](playtest-gap.md). No pass/fail row is asserted for a protocol the build cannot run.

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes (judgement) | [`notes.md`](notes.md) | present |
| Setup and seam | [`setup-and-seam.md`](setup-and-seam.md) | present |
| Playtest gap | [`playtest-gap.md`](playtest-gap.md) | present |
| Import log | [`logs/godot-import.log`](logs/godot-import.log) | present |
| GUT suite log | [`logs/gut-accept.log`](logs/gut-accept.log) | present |
| Seam probe (O8/O3) | [`logs/seam-probe.log`](logs/seam-probe.log) | present |
| Pack generator + its tests | [`logs/pack-generator-check.log`](logs/pack-generator-check.log) | present |
| Independent pack audit | [`logs/independent-pack-audit.log`](logs/independent-pack-audit.log) | present |
| Screenshot — `E-puzzle` PS1.1 judged state | `screenshots/open-10-15-20.png` | **waiting on a graphical re-run of the same build** |
| Screenshot — `PTD-ready-and-marks` judged state | `screenshots/ready-and-marks.png` | **waiting on a graphical re-run of the same build** |
