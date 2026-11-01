# Playtest run — issue #110 (graphical acceptance)

- **Issue:** #110 Puzzle screen: grid & clue bars (`type:task`, parent #93, `UI-puzzle`)
- **Run id:** `2026-11-02-accept-graphical`
- **Build / session:** `main@43d2064`, Godot 4.7.2.stable, session `issue-110-capture`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical (Metal, 900×1200)
- **Level:** UX (`UI-puzzle` US1.1–US1.7) plus `PTD-ready-and-marks`

## Scope

`UI-puzzle` is owned by #110 ([`story-rows.md`](../../../../../specs/playtest/story-rows.md)). The screen
shipped in PR #152 (`2601fee`) and PR #164 (`bc438de`); `game/presentation/puzzle*` is unchanged since
`859d834`, so that commit's deterministic record still describes this code. Gallery, result, settings,
and O4 pause are #94/#95/#96, deferred.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `US1.1` Ready chrome | **pass** | reopened record shows `0:12`; R1 Leave/Settings/elapsed; C1–C6 available |
| `US1.2` Board hides solution | **pass** | marks and clues drawn; no `TextureRect` |
| `US1.3` Tools | **pass** | C3 → C4 → C5 select Fill/Cross/Clear, each writes |
| `US1.4` Leave (partly) | **pass (intent)** | C1 raises `IN.back`; gallery is #94 |
| `US1.5` Cell when allowed | **pass** | tap with Fill shows fill |
| `US1.5b` Cell blocked | **pass** | taps in S2/S3 leave marks unchanged |
| `US1.6` Pause (screen leg) | **pass (seam)** | C6 raises `IN.pause`; S3 board unchanged, elapsed frozen; settings/O4 are #95/#96 |
| `US1.7` Get-set-ready | **pass** | `copy.ready` visible, marks blocked, C1/C6 on, C3–C5 off |
| Layout / palette / structure | **pass** | R1–R3 and S1–S3 per approved `MC.puzzle` |
| `PTD-ready-and-marks` S1–S3 | **pass** | blocked beat, fill/cross/clear, auto-cross rows 0 and 9 |
| `PTU-play-puzzle` | **deferred** | needs gallery and result (#94/#95) |
| `PTU-leave-resume` | **deferred** | needs `UI-gallery` (#94) |
| `PTD-ready-and-marks` S4 | **deferred** | needs settings (#95/#96) |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-s2-get-set-ready.png) | S2: `copy.ready`, marks blocked, C1/C6 on, C3–C5 off, `0:12` |
| [`01`](screenshots/01-s1-ready-restored-elapsed.png) | S1: restored fill, auto-crosses, clues, tools |
| [`02`](screenshots/02-fill-applied.png) | Fill applied to a clear cell |
| [`03`](screenshots/03-cross-selected.png) | Cross applied |
| [`04`](screenshots/04-clear-selected.png) | Clear applied |
| [`05`](screenshots/05-s3-paused.png) | S3: board unchanged, `0:12` frozen, marks blocked |
| [`06`](screenshots/06-after-leave.png) | C1 raised `IN.back`; shell returned home |

## Paths

| Artifact | Path |
|----------|------|
| Notes, criteria | [`notes.md`](notes.md), [`criteria.md`](criteria.md) |
| Probe (copied to `game/`, removed after) | [`probe/probe_capture_110.gd`](probe/probe_capture_110.gd) |
| Capture console, 7 shots | [`logs/capture-console.log`](logs/capture-console.log) |
| Shipped suite: 142/142, exit 0 | [`logs/gut-suite.log`](logs/gut-suite.log) |

## Quality evaluator

Deterministic: [`issue-110/2026-11-01T190448Z`](../../../../quality/evidence/issue-110/2026-11-01T190448Z/manifest.md)
— `frame-time`, `hitch-bound`, `crash-free`, `response-delay` all **pass**. `llm-judge`: N/A — no
domain axes are declared.

## Reproduce

Copy the probe to `game/probe_capture_110.gd`, then run it graphically (not `--headless`),
with `RUN` set to this folder:

```
godot --path game -s res://probe_capture_110.gd -- --debug-seams \
    --session-id=issue-110-capture --shot-dir="$RUN/screenshots"
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```

The probe exits 1 unless all seven judged states were saved and no check failed.
