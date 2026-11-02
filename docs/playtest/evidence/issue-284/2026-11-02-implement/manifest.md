# Playtest run — issue #284 (J-settings journey leg)

- **Issue:** #284 Settings journey `J-settings`: gallery → toggle → gallery (`type:task`, parent #95, journey `J-settings`)
- **Run id:** `2026-11-02-implement`
- **Runner:** `issue-workflow-implement-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `task/284-j-settings-journey@5e190c6`, Godot 4.7.2.stable, session `issue-284-journey-graphical`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (Xvfb, 900×1400)
- **Level:** UX (`J-settings` US1.1 / US1.2, protocol [`PTU-settings`](../../../../../specs/playtest/ux/settings.md))
- **Mockups:** `MC.settings-mobile` / `MC.settings-desktop` / `MC.settings-journey` are `approved` ([`catalog.md`](../../../../../specs/ux/mockups/catalog.md)); this task changes no screen rendering.

## Scope

The settings detour over the shipped screens: `UI-gallery.C3` opens `UI-settings`, one
preference toggle keeps the screen, `UI-settings.C3` returns to `UI-gallery`, and a re-open
shows the toggled value. Both branches — haptics (`C1`, US1.1) and mute (`C2`, US1.2 / B1) —
were driven through the real controls on the built shell. No routing, rendering, or player
change is part of this deliverable.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `J-settings` US1.1 — haptics detour (N1, N2, S1, S2, S3) | **pass** | C3 opens settings, C1 flips haptics only, C3 returns to the same gallery |
| `J-settings` US1.2 — mute branch (B1) | **pass** | C2 flips mute only and keeps UI-settings shown |
| `PTU-settings` S1–S3, P1 | **pass** | gallery → settings → Back → gallery |
| `PTU-settings` P2 | **pass** | toggled pref is still shown when settings reopens in the session |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-gallery-default.png) | N1: the app starts on `UI-gallery` |
| [`01`](screenshots/01-settings-haptics-before.png) | S1: settings open, Haptics On, Mute music Off |
| [`02`](screenshots/02-settings-haptics-after.png) | S2: C1 toggled haptics Off, screen still `UI-settings` |
| [`03`](screenshots/03-gallery-after-haptics-back.png) | S3: C3 returned to the unchanged gallery |
| [`04`](screenshots/04-settings-haptics-reopened.png) | P2: reopened settings still shows Haptics Off |
| [`05`](screenshots/05-settings-mute-before.png) | B1: settings open for the mute branch, Mute music Off |
| [`06`](screenshots/06-settings-mute-after.png) | B1: C2 toggled mute On, screen still `UI-settings` |
| [`07`](screenshots/07-gallery-after-mute-back.png) | B1/S3: C3 returned to the gallery |
| [`08`](screenshots/08-settings-mute-reopened.png) | P2: reopened settings still shows Mute music On |

## Paths

| Artifact | Path |
|----------|------|
| Notes, criteria | [`notes.md`](notes.md) |
| Probe (removed from `game/` after the run) | [`probe/probe_journey_284.gd`](probe/probe_journey_284.gd) |
| Capture console (27/27 checks, exit 0) | [`logs/probe-graphical.log`](logs/probe-graphical.log) |
| Suite at `5e190c6`: 20 scripts, 246/246, exit 0 | [`logs/gut-suite.log`](logs/gut-suite.log) |
| Godot import at `5e190c6` | [`logs/godot-import.log`](logs/godot-import.log) |

## Quality evaluator

Deterministic: N/A — no `Applies` axis cites this journey layer. `llm-judge`: N/A — no
domain axes are declared. Reproduce steps: [`notes.md`](notes.md).
