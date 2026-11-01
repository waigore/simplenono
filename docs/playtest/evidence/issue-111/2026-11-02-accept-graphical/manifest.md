# Playtest run — issue #111 (graphical acceptance)

- **Issue:** #111 UI actions: mark input (`type:task`, parent #93, story `IN`)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@b1c1285`, Godot 4.7.2.stable, session `issue-111-capture`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (Metal, 900×1200)
- **Level:** UX (`IN` US1.6 / US1.6b / US1.7 / US1.8)

## Scope

Graphical re-run of the held acceptance for #111. The deliverable is PR
[#154](https://github.com/waigore/simplenono/pull/154) (`b99b31d`); the first acceptance run
([`../2026-11-02-accept/`](../2026-11-02-accept/manifest.md)) judged it headless at the
`CTR-attempt` O2 seam and left the images waiting. This run supplies them on the current tree.
Since `b99b31d` the mark path changed only by #196's `mark_accepted` feedback signal and
#169's `debug/seams_enabled` flag. The story is `IN`
([`story-rows.md`](../../../../../specs/playtest/story-rows.md)).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `IN` US1.6 — tap applies the selected tool | **pass** | Fill on a clear cell marks and draws fill |
| `IN` US1.6b — tap toggles a same-mark cell off | **pass** | second tap on the filled cell clears it |
| `IN` US1.7 — complement | **pass** | Fill selected, complement on a clear cell draws a cross |
| `IN` US1.8 — drag-paint, no per-cell toggle | **pass** | Cross drag over a 3-cell run writes all three, origin included |
| `IN` blocked marks (`SEQ-mark` B1, `CTR-attempt` G1) | **pass** | a tap in get-set-ready leaves the grid unchanged |
| `PTU-settings` | not runnable for these clauses | the only protocol citing `IN`; it never places a mark |
| `PTD-ready-and-marks` | out of scope | design-level `Cites` omits `IN` |
| `PTU-mark-input` | **missing** | #203 authors it; [`deadlock`](../../accept-dispatch-deadlock.md) |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-s2-mark-blocked.png) | S2: `Ready` over a dimmed board, marks blocked, a tap writes nothing |
| [`01`](screenshots/01-us16-tap-fill.png) | US1.6: Fill applied to a clear cell (row 1, column 0) |
| [`02`](screenshots/02-us16b-tap-toggles-off.png) | US1.6b: the same tap again clears the cell |
| [`03`](screenshots/03-us17-complement-cross.png) | US1.7: Fill selected, complement draws a cross (row 2, column 0) |
| [`04`](screenshots/04-us18-drag-run.png) | US1.8: Cross drag over row 2 columns 0–2; all three carry a cross |

## Paths

| Artifact | Path |
|----------|------|
| Notes, criteria | [`notes.md`](notes.md), [`criteria.md`](criteria.md) |
| Probe (removed from `game/` after the run) | [`probe/probe_capture_111.gd`](probe/probe_capture_111.gd) |
| Capture console, state dump | [`logs/capture-console.log`](logs/capture-console.log), [`logs/state-pack-000.json`](logs/state-pack-000.json) |
| Suite at `b1c1285`: 17 scripts, 198/198, exit 0 | [`logs/gut-suite.log`](logs/gut-suite.log) |
| O2-sequence probe: 6/6, exit 0 | [`logs/probe.log`](logs/probe.log) |

## Quality evaluator

Deterministic: N/A — no Applies axis can move at this layer. `llm-judge`: N/A — no domain
axes are declared. Reproduce steps: [`notes.md`](notes.md).
