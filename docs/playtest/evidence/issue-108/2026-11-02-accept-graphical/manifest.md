# Playtest run — issue #108 (graphical acceptance)

- **Issue:** #108 Derived game state & invariants (`type:task`, `priority:normal`, parent #93, Wave 1)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@1015ee9`, Godot 4.7.2.stable, session `issue-108-capture`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical (Metal, 900×1200, viewport images)
- **Level:** Design (`GS`, `PTD-ready-and-marks` P2)

## Scope

`GS` is owned by #108. Deliverables: PR [#133](https://github.com/waigore/simplenono/pull/133)
(`04b1510`) and [#158](https://github.com/waigore/simplenono/pull/158) (`6eeef24`), merged.
Scope: [`notes.md`](notes.md#scope). Criteria: [`criteria.md`](criteria.md).

Supersedes the headless seam run [`2026-11-02-accept`](../2026-11-02-accept/manifest.md)
(`main@67e36f5`), which had no display and no `DBG.*` / `TEL.*` seam.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PS1.1`–`PS1.4b` / `V5` | **pass** | solve and line status derive only; wrong fills stay playable |
| `PS1.5` / `H1` | **pass** | thumbnail flag tracks `ever_completed` both ways |
| `PS1.6` / `V2` | **pass** | first fill sets in progress; empty-clue rows auto-cross at Ready |
| `PS1.7` / `Q1` | **pass** | two replays of one sequence give identical outcome |
| `V1`, `V3`, `V6` | **pass** | fresh open not started at `0:00`; reset → not started, `0`, no marks |
| `PTD-ready-and-marks` S1–S3 (P2) | **pass** | fresh blocked beat, Ready transitions, auto-cross |
| `PS1.2` 200-puzzle / `PS1.5` picture | **deferred** | #94 / #97 / #98 |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-fresh-ready-blocked.png) | fresh get-set-ready: marks blocked, all cells clear, `0:00`, attempt not started |
| [`01`](screenshots/01-ready-fill-clear-cross.png) | Ready: empty-clue rows 0 and 9 auto-crossed, tapped cell crossed, attempt in progress |
| [`02`](screenshots/02-wrong-fill-playable.png) | a wrong fill at (3,0) stays, no fail state |
| [`03`](screenshots/03-invariants-ready.png) | after the replay and `DBG.2` reads: board unchanged, still playable |
| [`04`](screenshots/04-after-reset.png) | after `CTR-pack` O7 and `AttemptState.clear_attempt`: not started, `0:00`, no marks |

The board is `MC.puzzle`'s approved drawing (`#110`); the judged derived values appear through the
`DBG.4` story overlay (`story: GS, …`) and `DBG.2` in the console log.

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes, criteria, falsification | [`notes.md`](notes.md), [`criteria.md`](criteria.md), [`falsification.md`](falsification.md) | present |
| Capture probe, run once and removed from `game/` | [`probe/probe_capture_108.gd`](probe/probe_capture_108.gd) | present |
| Capture console (`TEL.*`, every `capture: PASS`) | [`logs/capture-console.log`](logs/capture-console.log) | 5 shots, exit 0 |
| Shipped suite | [`logs/gut-suite.log`](logs/gut-suite.log) | 11 scripts, 139/139, 29 204 asserts, exit 0 |
| Falsification runs (3 caught, 1 surviving) | [`falsification.md`](falsification.md) | logs under `logs/falsify-*.log` |

Stored logs are the native runs as emitted (ANSI colour codes aside); every assertion line and exit
status is kept.

## Quality evaluator

N/A — no Applies deterministic axis can move (in-memory domain rules: no frame, launch, save-file,
or crash surface) and no record exists for it; `llm-judge` is N/A, no domain axes are declared.

## Reproduce

See [`notes.md`](notes.md#reproduce).
