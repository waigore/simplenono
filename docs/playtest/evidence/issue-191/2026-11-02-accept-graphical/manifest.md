# Playtest run — issue #191 (graphical acceptance)

- **Issue:** #191 Shell audio, haptics, and the asset resolver (`type:task`, parent #93)
- **Run id:** `2026-11-02-accept-graphical`
- **Build / session:** `main@52db79a`, Godot 4.7.2.stable, session `issue-191-accept`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** graphical (900×1200) for screenshots and audio; one headless re-run

## Scope

Presentation plumbing: mark ticks, music bed, solve sting, haptic click, and the manifest
resolver. The five deliverable files are byte-identical between `cd08f79` and this build
([`logs/deliverable-scope.log`](logs/deliverable-scope.log)); only gallery routing (#199)
changed the shell since. `PTD-ready-and-marks` S1–S3 supplies the mark states where
`SND.X1`–`X3` fire. **No design story or protocol cites `SND.*` or `HAP.H1`**, so playback
is judged from player state and logs; see [`notes.md`](notes.md).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-ready-and-marks` S1 | **pass** | get-set-ready blocks the mark; no tick |
| `PTD-ready-and-marks` S2 | **pass** | fill → cross → clear, each own tick |
| `PTD-ready-and-marks` S3 | **pass** | paused taps change nothing, play nothing |
| `PTD-ready-and-marks` S4 | **deferred** | needs settings (#95/#96) |
| `SND.X1`–`X3` mark ticks | **pass** | one per accepted mark; none for B1/B2 |
| `SND.M1` bed | **pass** | starts/loops on open, stops on leave, F2 mutes |
| `SND.M2` solve sting | **pass** | once at E1 over the continuing bed; duplicate silent |
| `HAP.H1` haptic | **pass (seam)** | 0.25/20 ms, fill/cross, mobile only, F1-gated |
| `SCH-preferences` F1/F2/I1 | **pass** | defaults on/off, session-only, bed-only mute |
| `PTU-settings` | **not applicable** | needs `UI-settings` (#95) |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-open-bed-playing.png) | Puzzle open; bed player on `music/bed.mp3`, playing |
| [`01`](screenshots/01-fill-tick.png) | Accepted fill; `SND.X1` player playing |
| [`02`](screenshots/02-cross-tick.png) | Accepted cross; `SND.X2` playing |
| [`03`](screenshots/03-clear-tick.png) | Accepted clear; `SND.X3` playing |
| [`04`](screenshots/04-solve-sting.png) | Grid that solved (no repaint after S11; result is #95); `SND.M2` playing |
| [`05`](screenshots/05-after-leave-bed-stopped.png) | After C1 leave: bed stopped, gallery shown |

## Paths

| Artifact | Path |
|----------|------|
| Notes, criteria, falsification | [`notes.md`](notes.md), [`criteria.md`](criteria.md), [`falsification.md`](falsification.md) |
| Probe (copied to `game/`, removed after) | [`probe/probe_accept_191.gd`](probe/probe_accept_191.gd) |
| Graphical probe, 79 checks + 6 shots | [`logs/probe-graphical.log`](logs/probe-graphical.log) |
| Headless probes | [`logs/probe-headless.log`](logs/probe-headless.log), [`logs/probe-headless-restored.log`](logs/probe-headless-restored.log) |
| Suite 185/185; lint clean; smoke, manifest, spec lint | [`logs/`](logs/) |

## Quality evaluator

Deterministic: [`issue-191/2026-11-02-verify`](../../../../quality/evidence/issue-191/2026-11-02-verify/manifest.md)
— `frame-time`, `hitch-bound`, `response-delay`, `crash-free` all **pass**. `llm-judge`: N/A
(no domain axes).

## Reproduce

Copy the probe to `game/probe_accept_191.gd`, then:

```
godot --headless --path game --import
godot --path game -s res://probe_accept_191.gd -- --shot-dir="$RUN/screenshots"
godot --headless --path game -s res://probe_accept_191.gd -- --no-shots
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```
