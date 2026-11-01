# Playtest Traceability

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../.agents/specs/rules/playtest/traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Solve loop / endings / progression | design | [`design/ready-and-marks.md`](design/ready-and-marks.md), [`design/solve-and-pb.md`](design/solve-and-pb.md), [`design/crosses-and-fills.md`](design/crosses-and-fills.md), [`design/pack-finished.md`](design/pack-finished.md) |
| Cell / clue / game-state / puzzle | design | [`design/ready-and-marks.md`](design/ready-and-marks.md), [`design/crosses-and-fills.md`](design/crosses-and-fills.md) |
| Play / leave-resume / reset / settings journeys | ux | [`ux/play-puzzle.md`](ux/play-puzzle.md), [`ux/leave-resume.md`](ux/leave-resume.md), [`ux/gallery-reset.md`](ux/gallery-reset.md), [`ux/settings.md`](ux/settings.md) |
| Gallery, puzzle, result, settings screens | ux | Same UX protocols as journeys above |
| Calm pack play; snappy solve | vision / definition | Hub + all protocols |
| Debug UI & telemetry | definition / technical | [`tools.md`](tools.md), hub architecture |

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Tools (debug UI, telemetry) | [`tools.md`](tools.md) | Applies |
| Procedures | [`procedures.md`](procedures.md) | Applies |
| Evidence | [`evidence.md`](evidence.md) | Applies |
| Coverage mode | [`coverage.md`](coverage.md), [`playtest.md`](playtest.md) | Applies |
| Design protocols | [`design/`](design/) | Applies |
| UX protocols | [`ux/`](ux/) | Applies |
| ADR / technical constraints | [`tools.md`](tools.md), hub architecture constraints | Applies |
