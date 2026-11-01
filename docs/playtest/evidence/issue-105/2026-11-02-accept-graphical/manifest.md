# Playtest run — issue #105 (graphical)

- **Issue:** #105 Pack data & loader per ADR-0004 (`type:task`, parent #93)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@effca0a`, Godot 4.7.2.stable; session `issue-105-capture`
- **Coverage mode:** `full` · **Run type:** graphical (Metal 4.0, 900×1200, viewport images)
- **Level:** Design — `E-puzzle` PS1.1, `PTD-ready-and-marks` S1–S4 / P1–P3

## Scope

The deliverable is PR [#124](https://github.com/waigore/simplenono/pull/124), squash `4c8d1e5`.
`#169` (`3f402fe`) supplied the S1–S5 seams [`verification.md`](../../../../../specs/technical/verification.md)
H1 requires and `#110` draws the board, so E-puzzle's claim has a screen state for the first time.
`PTU-play-puzzle` is not runnable (no gallery or result screen, #94/#95).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `E-puzzle` PS1.1 P1 size | **pass** | 10×10, 15×15, 20×20 boards opened |
| `E-puzzle` PS1.1 P3 clues | **pass** | every drawn clue bar equals the entry's F3/F4 runs |
| `E-puzzle` PS1.1 P2 solution | **pass** | filling `solution_fills` on `pack-000` solves |
| `E-puzzle` PS1.1 P4 identity | **pass** | served id matches; unknown id changes nothing |
| `PTD-ready-and-marks` S1–S4 | **pass** | `00`–`07`; no `F1`/`F2` trigger |
| `PTD-ready-and-marks` P2 | **pass** | `pack-000` empty clue rows 0/9 auto-cross |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-ready-blocked-10x10.png) | 10×10 get-set-ready, marks blocked, `0:00` |
| [`01`](screenshots/01-ready-marks-10x10.png) | Ready after fill → clear → cross |
| [`02`](screenshots/02-wrong-fill-10x10.png) | wrong fill, still playable |
| [`03`](screenshots/03-solved-10x10.png) | solved from the pack's own fills |
| [`04`](screenshots/04-ready-15x15.png) | 15×15 Ready, its clue bars |
| [`05`](screenshots/05-ready-20x20.png) | 20×20 Ready, its clue bars |
| [`06`](screenshots/06-paused-15x15.png) | paused, mark ignored, `0:18` frozen |
| [`07`](screenshots/07-resumed-15x15.png) | resumed, fill applies |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes, criteria | [`notes.md`](notes.md), [`criteria.md`](criteria.md) | present |
| Capture probe, removed from `game/` after the run | [`probe/probe_capture_105.gd`](probe/probe_capture_105.gd) | present |
| Capture console (`TEL.*`, every `capture: PASS`) | [`logs/capture-console.log`](logs/capture-console.log) | 306 passes, 0 fails, exit 0 |
| Shipped suite | [`logs/gut-suite.log`](logs/gut-suite.log) | 11 scripts, 139/139, exit 0 |
| Independent pack audit | [`logs/independent-pack-audit.log`](logs/independent-pack-audit.log) | 200 entries, 0 errors |

Logs are native runs stripped of ANSI.

## Quality evaluator

No Applies deterministic axis can move from an L3 pack load: no frame, load budget, transition,
persistence, or crash surface. No `llm-judge` axis applies —
[`rubrics.md`](../../../../../specs/definition/quality/rubrics.md) declares no domain axes.

## Reproduce

See [`notes.md`](notes.md#reproduce).
