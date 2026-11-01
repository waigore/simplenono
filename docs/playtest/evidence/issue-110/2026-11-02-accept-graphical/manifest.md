# Playtest run — issue #110 (graphical acceptance)

- **Issue:** #110 Puzzle screen: grid & clue bars (`type:task`, `priority:normal`, parent #93, `UI-puzzle`)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@43d2064`, Godot 4.7.2.stable, session `issue-110-capture`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical (Metal, 900×1200, viewport images)
- **Level:** UX (`UI-puzzle`, US1.1–US1.7); design clauses of `PTD-ready-and-marks`

## Scope

`UI-puzzle` is owned by #110 ([`story-rows.md`](../../../../../specs/playtest/story-rows.md)). The screen was
delivered by PR #152 (`2601fee`) and PR #164 (`bc438de`); `git log 859d834..HEAD -- game/presentation/puzzle*`
is empty, so the deterministic record for `859d834` describes the same screen code this run judged on `43d2064`.

The run drove the real shell (`shell.tscn`) and the shipped `PuzzleScreen` + `MarkInput`. Gallery, result,
settings, and the O4 pause write are still #94/#95/#96, so the protocols that need them are recorded as
deferred below, exactly as the passing review and verify scoped them.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `US1.1` Ready chrome | **pass** | reopened record shows `0:12`; R1 Leave, Settings, elapsed; C1–C6 available |
| `US1.2` Board hides solution | **pass** | marks and clues drawn; zero `TextureRect`; restored fill visible |
| `US1.3` Tools | **pass** | C3 → C4 → C5 select Fill → Cross → Clear, and each writes through `MarkInput` |
| `US1.4` Leave (partly) | **pass (intent)** | C1 raises `IN.back`; gallery itself is #94 |
| `US1.5` Cell when allowed | **pass** | a tap on a clear cell with Fill shows fill |
| `US1.5b` Cell blocked | **pass** | taps in S2 and S3 leave cell-marks unchanged |
| `US1.6` Pause (screen leg) | **pass (seam)** | C6 raises `IN.pause`; S3 board unchanged, elapsed frozen at `0:12`. Settings screen + `GS.paused` write are #95/#96 |
| `US1.7` Get-set-ready | **pass** | `copy.ready` visible, marks blocked, C1/C6 available, C3–C5 disabled |
| Layout / palette / structure | **pass** | R1/R2/R3 present; `copy.*` strings; approved `MC.puzzle` drawing |
| `PTD-ready-and-marks` S1–S3 | **pass** | S2 blocks a mark; Ready fill/cross/clear transitions; auto-cross rows 0 and 9 |
| `PTU-play-puzzle` | **deferred** | gallery → result route is #94/#95; not runnable on this build |
| `PTU-leave-resume` | **deferred** | needs `UI-gallery` (#94); #110 only raises `IN.back` |
| `PTD-ready-and-marks` S4 | **deferred** | pause settings surface is #95/#96 |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-s2-get-set-ready.png) | S2 get-set-ready: `copy.ready` beat, marks blocked, C1/C6 enabled, C3–C5 disabled, restored `0:12` |
| [`01`](screenshots/01-s1-ready-restored-elapsed.png) | S1 Ready: R1 Leave/Settings/`0:12`, R2 restored fill + auto-crosses + clues, R3 tools |
| [`02`](screenshots/02-fill-applied.png) | Fill selected; a tap on the clear cell shows fill |
| [`03`](screenshots/03-cross-selected.png) | Cross selected; the same cell holds a cross |
| [`04`](screenshots/04-clear-selected.png) | Clear selected; the cell is clear again |
| [`05`](screenshots/05-s3-paused.png) | S3 Paused: board unchanged, elapsed frozen at `0:12`, marks blocked |
| [`06`](screenshots/06-after-leave.png) | C1 raised `IN.back`; the shell returned to its home view (gallery is #94) |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes, criteria | [`notes.md`](notes.md), [`criteria.md`](criteria.md) | present |
| Capture probe, copied to `game/` for the run and removed after | [`probe/probe_capture_110.gd`](probe/probe_capture_110.gd) | present |
| Capture console (`TEL.*`, every `capture: PASS`) | [`logs/capture-console.log`](logs/capture-console.log) | 7 shots, exit 0 |
| Shipped suite | [`logs/gut-suite.log`](logs/gut-suite.log) | 11 scripts, 142/142, 29 229 asserts, exit 0 |

Stored logs are the native runs as emitted (ANSI colour codes aside); every assertion line and exit
status is kept.

## Quality evaluator

Deterministic: [`docs/quality/evidence/issue-110/2026-11-01T190448Z/manifest.md`](../../../../quality/evidence/issue-110/2026-11-01T190448Z/manifest.md)
— `frame-time`, `hitch-bound`, `crash-free`, `response-delay` all **pass** for the same screen code.
`llm-judge`: N/A — no domain axes are declared (`specs/definition/quality/rubrics.md`).

## Reproduce

With the probe copied to `game/probe_capture_110.gd`:

```
godot --headless --path game --import
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit

RUN=<this folder>
mkdir -p "$RUN/screenshots"
godot --path game -s res://probe_capture_110.gd -- \
    --debug-seams --session-id=issue-110-capture \
    --story-ids=UI-puzzle,US1.1,US1.2,US1.3,US1.4,US1.5,US1.5b,US1.6,US1.7 \
    --shot-dir="$RUN/screenshots"
```

The probe quits 1 unless all seven judged states were saved and no check failed. The run must be
graphical (`godot --path game`, not `--headless`).
