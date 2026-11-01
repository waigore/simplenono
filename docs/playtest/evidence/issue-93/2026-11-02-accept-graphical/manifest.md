# Playtest run — issue #93 (graphical acceptance)

- **Issue:** #93 Core solve loop vertical (`type:epic`, Wave 1 — Playable core solve loop)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@94e6c55`, Godot 4.7.2.stable, session `issue-93-capture`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (Metal, 900×1200)
- **Levels:** Design (`PTD-ready-and-marks`, `PTD-crosses-and-fills`, `PTD-solve-and-pb`) and UX (`PTU-play-puzzle`)

Scope selection is in [`criteria.md`](criteria.md) and the per-row results are in
[`results.md`](results.md); the narrative observations are in [`notes.md`](notes.md); the 17
judged screenshots and the state each one shows are in [`screenshots.md`](screenshots.md).

## Paths

| Artifact | Path |
|----------|------|
| Criteria (scope), results | [`criteria.md`](criteria.md), [`results.md`](results.md) |
| Screenshot index (17 images) | [`screenshots.md`](screenshots.md) |
| Probe (removed from `game/` after the run) | [`probe/probe_capture_93.gd`](probe/probe_capture_93.gd) |
| Capture console (133 passing checks, telemetry) | [`logs/capture-console.log`](logs/capture-console.log) |
| State dumps (`DBG.2` / `SIT.3`) | [`logs/state-pack-000.json`](logs/state-pack-000.json), [`logs/state-pack-002.json`](logs/state-pack-002.json) |
| GUT suite at `94e6c55`: 19 scripts, 215/215, 29 956 asserts, exit 0 | [`logs/gut-suite.log`](logs/gut-suite.log) |

## Reproduce

```sh
godot --path game -s res://probe_capture_93.gd -- --debug-seams \
  --session-id=issue-93-capture --build-id=main@94e6c55 \
  --story-ids=L-solve,E-cell,E-clue,GS,E-puzzle,J-play-puzzle,UI-puzzle \
  --shot-dir=<run folder>/screenshots --dump-dir=<run folder>
```

Copy [`probe/probe_capture_93.gd`](probe/probe_capture_93.gd) into `game/` first; remove it
afterward. Exit code 0 means every judged state was reached.

## Quality evaluator

`deterministic`: cited from verification, not re-run here — see the acceptance comment.
`llm-judge`: N/A — no domain axes are declared ([`rubrics.md`](../../../../../specs/definition/quality/rubrics.md)).
