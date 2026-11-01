# Playtest run — issue #191 (graphical acceptance)

- **Issue:** #191 Shell audio, haptics, and the asset resolver (`type:task`, parent #93, `CMP-shell` R4/R6)
- **Run id:** `2026-11-02-accept-graphical`
- **Build / session:** `main@52db79a`, Godot 4.7.2.stable, session `issue-191-accept`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical (900×1200) for the screenshots and the audio path; one headless re-run of the same probe

## Scope

The deliverable is presentation plumbing: the mark ticks, the music bed, the solve sting,
the haptic click, and the manifest resolver. The five deliverable files
(`audio_cues.gd`, `audio_feedback.gd`, `haptics.gd`, `session_flags.gd`, `mark_input.gd`) are
byte-identical between the deliverable commit `cd08f79` and this build
([`deliverable-scope.log`](logs/deliverable-scope.log)); the shell's audio callbacks are
unchanged (gallery routing from #199 is the only shell change since).

`PTD-ready-and-marks` S1–S3 supplies the mark states in which `SND.X1`–`X3` fire, so the
graphical images record those judged states. **No design story or protocol cites `SND.*`
or `HAP.H1`** — the only protocol that mentions the haptics preference is `PTU-settings`,
which judges the settings screen (#95). Playback is therefore judged from the probe's player
and log observations, not from a picture; the gap is recorded in [`notes.md`](notes.md).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-ready-and-marks` S1 | **pass** | get-set-ready blocks the mark; no tick fires |
| `PTD-ready-and-marks` S2 | **pass** | fill → cross → clear through `MarkInput`; each plays its own tick and updates the grid |
| `PTD-ready-and-marks` S3 | **pass** | paused taps leave the grid unchanged and play nothing |
| `PTD-ready-and-marks` S4 | **deferred** | needs settings (#95/#96) |
| `SND.X1`/`X2`/`X3` mark ticks | **pass** | one tick per accepted fill, cross, clear; none for B1/B2 |
| `SND.M1` bed | **pass** | starts on open, loops, stops on leave, muted by F2 only |
| `SND.M2` solve sting | **pass** | plays once at `CTR-attempt.E1` over the continuing bed; duplicate E1 does not restart it |
| `HAP.H1` haptic | **pass (seam)** | 0.25 / 20 ms, fill and cross only, iOS/Android only, F1-gated; macOS fires nothing |
| `SCH-preferences` F1/F2/I1 | **pass** | defaults on/off, session-only, F2 mutes the bed only |
| `PTU-settings` | **not applicable** | needs `UI-settings` (#95) |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-open-bed-playing.png) | Puzzle open; `SND.M1` bed player holds `music/bed.mp3` and is playing |
| [`01`](screenshots/01-fill-tick.png) | Accepted fill on a solution cell; `SND.X1` tick player playing |
| [`02`](screenshots/02-cross-tick.png) | Accepted cross; `SND.X2` tick player playing |
| [`03`](screenshots/03-clear-tick.png) | Accepted clear; `SND.X3` tick player playing |
| [`04`](screenshots/04-solve-sting.png) | The grid that solved the puzzle (the screen does not repaint after S11; the result screen is #95); `SND.M2` playing |
| [`05`](screenshots/05-after-leave-bed-stopped.png) | After C1 leave: the bed player is stopped and the shell shows the gallery |

## Paths

| Artifact | Path |
|----------|------|
| Notes, criteria | [`notes.md`](notes.md), [`criteria.md`](criteria.md) |
| Probe (copied to `game/`, removed after) | [`probe/probe_accept_191.gd`](probe/probe_accept_191.gd) |
| Graphical probe, 79 checks + 6 shots | [`logs/probe-graphical.log`](logs/probe-graphical.log) |
| Headless probes (restored tree) | [`logs/probe-headless.log`](logs/probe-headless.log), [`logs/probe-headless-restored.log`](logs/probe-headless-restored.log) |
| Falsification: bed start removed → 5 failures | [`logs/falsify-bed.log`](logs/falsify-bed.log) |
| Falsification: F1 gate removed → 1 failure | [`logs/falsify-haptics.log`](logs/falsify-haptics.log) |
| Shipped suite: 185/185, exit 0 | [`logs/gut-suite.log`](logs/gut-suite.log) |
| Lint (gdformat, gdlint): clean | [`logs/lint.log`](logs/lint.log) |
| Smoke, manifest, spec lint | [`logs/smoke.log`](logs/smoke.log), [`logs/repo-checks.log`](logs/repo-checks.log) |
| Deliverable commit vs this build | [`logs/deliverable-scope.log`](logs/deliverable-scope.log) |

## Quality evaluator

Deterministic: [`issue-191/2026-11-02-verify`](../../../../quality/evidence/issue-191/2026-11-02-verify/manifest.md)
— `frame-time`, `hitch-bound`, `response-delay`, `crash-free` all **pass**. `llm-judge`:
N/A — [`rubrics.md`](../../../../../specs/definition/quality/rubrics.md) declares no domain axes.

## Reproduce

Copy the probe to `game/probe_accept_191.gd`, then:

```
godot --headless --path game --import
godot --path game -s res://probe_accept_191.gd -- --shot-dir="$RUN/screenshots"
godot --headless --path game -s res://probe_accept_191.gd -- --no-shots
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```

The probe exits 1 unless every check passes and, in graphical mode, all six judged
states were saved.
