# Playtest run — issue #511 (graphical acceptance)

- **Issue:** #511 Settings: mobile portrait↔landscape orientation control (`type:task`, `priority:high`)
- **Run id:** `2026-11-04-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-04
- **Build / session id:** `main@51dfe86` (carries PR [#518](https://github.com/waigore/simplenono/pull/518) squash `5868833`), Godot 4.7.2.stable, session `issue-511-accept`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (900×1200),
  Vulkan Forward+ on llvmpipe under Xvfb, Linux x86_64, fresh `user://` (isolated `HOME`)
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-511-2026-11-04-accept-graphical>

## Scope

#511 adds `UI-settings.C4`, the mobile Settings orientation control. The judged protocol is
[`PTU-settings`](../../../../../specs/playtest/ux/settings.md) in full: S1–S5, P1–P4, F1–F3.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| `PTU-settings` S1 / P1 / F1 | gallery → settings → Back, with `C4` in `R1` |
| `PTU-settings` S2 / P2 / F2 | C1/C2 toggle and the choice sticks on re-open |
| `PTU-settings` S4 / P3 / F3 | `C4` shows Portrait/Landscape and the screen stays locked to the choice |
| `PTU-settings` S5 / P4 / F3 | relaunch restores the stored choice; a tilt does not rotate it |

Out of scope: every other protocol. The change touches `game/presentation/settings.gd`,
`settings.tscn`, `shell.gd` and the two settings test files only.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-settings` S1 / P1 | **pass** | gallery → settings → Back → gallery |
| `PTU-settings` S2 / P2 | **pass** | C1 toggled On → Off; the change reads back on re-open |
| `PTU-settings` S4 / P3 | **pass** | C4 shows Portrait; activating asks for and locks Landscape at once, stays on Settings |
| `PTU-settings` S5 / P4 | **pass** | relaunch restores the stored Landscape and locks it; a tilt both ways leaves it in place |
| `PTU-settings` F1 / F2 / F3 | **not triggered** | no open/back failure, no lost toggle, no missing C4, no rotation on tilt |

Capture: **40 checks `capture: PASS`, 0 `capture: FAIL`**, final line
`capture: RESULT pass (5 shots, 40 checks, 0 failed)`, exit 0 —
[wiki `logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-511-2026-11-04-accept-graphical).

## Judged states (wiki media, graphical run of this build)

| Wiki path (`playtest/issue-511/2026-11-04-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-settings-mobile-default-portrait.png` | S1 / AC 2 | mobile Settings `R1`: Haptics On, Mute music Off, Orientation Portrait (hint "Locked · no tilt"), Back last |
| `screenshots/02-settings-haptics-toggled.png` | S2 / P2 | C1 toggled to Off, copy follows |
| `screenshots/03-settings-c4-landscape.png` | S4 / P3 / AC 3 | after C4: Orientation Landscape, still on Settings, no relaunch |
| `screenshots/04-relaunch-stored-landscape-settings.png` | S5 / P4 | after force-quit + relaunch: C4 shows the restored Landscape |
| `screenshots/05-relaunch-after-tilts-upright.png` | P4 / F3 | after tilt left, tilt right, upright: identical upright frame |

## Paths

| Artifact | Path |
|----------|------|
| Notes, reproduction, device caveat | [`notes.md`](notes.md) |
| Probe (copied to `game/` for the run, removed after) | [`probe/probe_accept_511.gd`](../probe/probe_accept_511.gd) |
| Capture console (40 PASS, final RESULT) | wiki page, `logs/capture.log` |
| Screenshots (5, graphical run of this build) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic`: **cited, not re-run.** Verification wrote a passing record that covers this `game/` tree —
[`docs/quality/evidence/issue-511/2026-11-04-verify/manifest.md`](../../../../quality/evidence/issue-511/2026-11-04-verify/manifest.md)
(against `be4bd6a`); `git diff be4bd6a HEAD -- game/` is empty on `51dfe86`. `response-delay` (I8) and
`crash-free` (I9) are pass; no row is `fail` or `blocked`.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.
