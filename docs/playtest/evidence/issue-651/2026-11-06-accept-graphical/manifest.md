# Playtest run — issue #651 (graphical acceptance, hint settings toggles)

- **Issue:** #651 Hint settings: persisted toggles for all hint types
  (`type:task`, `status:pending-acceptance`, `priority:normal`)
- **Run id:** `2026-11-06-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-06
- **Build / session id:** `main@6a47af8`, session `issue-651-accept`, Godot
  `4.7.2.stable.official.ed1daf0bf`, Linux x86_64, Xvfb, fresh `user://` per phase.
  Frames: 390×844 (the approved `MC.settings-mobile` device frame) and 1280×800
  (`MC.settings-desktop`). The deliverable is the C5–C7 chrome from #677 (`903b921`)
  plus the #679 dedup (`3acbac1`); `6a47af8` is `main` at the run and adds only
  sibling evidence folders.
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-651-2026-11-06-accept-graphical>

## Scope

The deliverable is the three persisted hint-assist rows on `UI-settings` (C5
single-line, C6 multi-line, C7 line-fillable), writing through the presented
`HintPreferences` store (`SCH-preferences` F4–F6, ADR-0010), and the shell's
enable-during-attempt void path (`CTR-pack` O9, `DSGN.progression` PS1.9).

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-settings`](../../../../../specs/playtest/ux/settings.md) S1–S3 / P1 / P2 | Gallery → settings → Back; toggles stick on reopen and across a relaunch |
| `PTU-settings` S6 / P5 | Enabling a hint assist during an open attempt is observable for hint-free |
| `US1.8` | The three hint-assist toggles persist and prove C5–C7 |
| `MC.settings-mobile` / `MC.settings-desktop` | Labels, hint lines, default-off values, and row order |

Out of scope: `PTU-settings` S4–S5 / P3–P4 are mobile-device steps (situational tool:
a phone or tablet). This run is a desktop build, where C4 is absent by spec, so those
steps are not applicable — the same treatment as the #95 settings acceptance run.
`PTD-*` and the other `PTU-*` protocols are untouched by this deliverable.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-settings` S1 / P1 | **pass** | cold start on `UI-menu`; C1 reaches `UI-gallery`; gallery C3 opens `UI-settings`; C3 Back returns to the gallery |
| `PTU-settings` S2 / P2 | **pass** | C1 flips haptics Off; C5 flips the single-line assist On and the store holds it |
| `PTU-settings` S3 / P2 | **pass** | Back → reopen shows the values stuck; a fresh process on the same `user://` still shows single-line On |
| `PTU-settings` S6 / P5 | **pass** | a fresh attempt is hint-free eligible; enabling C6 while paused into settings voids it, and the void survives Back to the puzzle |
| `US1.8` | **pass** | the three hint-assist toggles persist and prove C5–C7 |
| `MC.settings-mobile` / `MC.settings-desktop` | **pass** | labels, hint lines, default-off values, and row order C1, C2, C5–C7, C3 match; C4 is absent on this desktop build |

Capture: `capture: RESULT pass` on every phase, exit 0 —
[`logs/probe-first.log`, `logs/probe-relaunch.log`, `logs/probe-void.log`, and `logs/probe-desktop.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-651-2026-11-06-accept-graphical).

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-651/2026-11-06-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-settings-default.png` | `PTU-settings` S1, `US1.8` | 390×844: C1 On, C2 Off, C5–C7 Off, C3 Back; C4 absent (desktop build) |
| `screenshots/02-settings-after-toggle.png` | `PTU-settings` S2, `P2` | 390×844: haptics Off, single-line hint On |
| `screenshots/03-settings-reopened.png` | `PTU-settings` S3, `P2` | 390×844: after Back and reopen, the values stuck |
| `screenshots/04-settings-after-relaunch.png` | `PTU-settings` S3, `P2` | 390×844: fresh process, single-line still On (durable) |
| `screenshots/05-settings-paused-with-enable.png` | `PTU-settings` S6, `P5` | 390×844: puzzle paused into settings, multi-line turned On |
| `screenshots/06-puzzle-after-enable.png` | `PTU-settings` S6, `P5` | 390×844: Back resumes the puzzle with the attempt voided for hint-free |
| `screenshots/desktop-01-settings-default.png` | `MC.settings-desktop` | 1280×800: the desktop control set, C4 absent |
| `screenshots/desktop-02-settings-after-toggle.png` | `MC.settings-desktop` | 1280×800: line-fillable hint On |

## Paths

| Artifact | Path |
|----------|------|
| Notes | [`notes.md`](notes.md) |
| Probe (copied to `game/`, removed after) | [`probe/probe_accept_651.gd`](probe/probe_accept_651.gd) |
| Screenshots and logs | <https://github.com/waigore/simplenono/wiki/Playtest-issue-651-2026-11-06-accept-graphical> |
