# Playtest run — issue #623 (graphical acceptance, main menu entry, gallery back, exit, stamp)

- **Issue:** #623 Main menu screen UI: entry, gallery back, exit, version stamp (`type:task`, `priority:high`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** `main` at `7d69040` (squash of PR #636, merged 2026-11-05T08:26:06Z).
  `game/` at `7d69040` is the tree under test; later `main` commits are evidence-only (#637).
  Session `issue-623-accept`, Godot 4.7.2.stable, Vulkan Forward+ on llvmpipe under Xvfb,
  desktop 1280×800 and mobile 390×844, Linux x86_64, fresh `user://` (isolated `HOME`).
  A release-shaped `game/release/build_info.json` (`0.1.0`, `7d69040`) was present for the
  run, so the stamp read the same document the export writes; it was removed afterwards.
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-623-2026-11-05-accept-graphical>

## Scope

The deliverable adds the main menu as the new-session front door (`NAV.N1`), wires
Puzzles → gallery, gallery **Back to main menu** (`NAV.T12`), desktop-only Exit
(`NAV.T11`), settings return-to-opener (`NAV.T10`/`T13`), and the bottom-left build stamp
from `CTR-build-info`; an interrupted session still resumes on the gallery (`NAV.N2`).
The protocol that owns this surface is `PTU-menu`.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-menu`](../../../../../specs/playtest/ux/menu.md) S1–S6 / P1–P6 | The whole delivered surface: first screen, Puzzles/Back, Settings/Back, Exit, mobile framing, stamp |
| AC — gallery Settings still works | The gallery chrome changed; its Settings path must still return to the gallery |
| AC / `NAV.N2` — interrupted resume | The boot decision changed; an in-progress record must still land on the gallery |

Out of scope: every other protocol — no puzzle, mark, result, pack, audio, or persistence
code is in the deliverable.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-menu` S1 / P1 | **pass** | cold launch shows `UI-menu`; gallery and puzzle are hidden |
| `PTU-menu` S1 / R1–R3, C1–C3 | **pass** | title `simplenono`; Puzzles, Settings, Exit; Exit drawn and available on desktop; focus order C1, C2, C3 |
| `PTU-menu` S1 / P6 | **pass** | stamp `v0.1.0 · 7d69040`, bottom-left at (32, 742) in 1280×800, `DIM` colour, non-empty |
| `PTU-menu` S2 / P2 | **pass** | C1 Puzzles opens `UI-gallery`; C4 reads Back to main menu and returns to `UI-menu` |
| `PTU-menu` S3 / P3 | **pass** | C2 Settings opens `UI-settings`; Back returns to the menu that opened it |
| `PTU-menu` S4 / P4 | **pass** | C3 Exit quits the app on the desktop build |
| `PTU-menu` S5 / P5 | **pass** | mobile framing draws Puzzles and Settings, no Exit; C3 cannot activate; only C1/C2 focusable |
| `PTU-menu` S5 / P6 | **pass** | the stamp is drawn on the mobile framing |
| `PTU-menu` S6 / P3 | **pass** | mobile Settings opens; Back returns to `UI-menu` |
| AC — gallery Settings | **pass** | gallery Settings opens settings; Back returns to the gallery, not the menu |
| AC / `NAV.N2` | **pass** | a seeded in-progress record boots on the gallery, not the menu |

Capture: `capture: RESULT pass (10 shots, 0 checks failed)`, 52 `capture: PASS` checks,
exit 0, no script errors.

The mobile leg uses the screen's own `mobile` seam on this desktop host (the same seam
GUT uses); the desktop-only Exit branch is also covered by
`test_exit_is_desktop_only`. No mobile OS build is available on this host.

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-623/2026-11-05-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-menu-desktop.png` | `PTU-menu` S1 / P1, P6 | cold launch: title, Puzzles, Settings, Exit, bottom-left stamp |
| `screenshots/02-gallery-back-to-menu.png` | `PTU-menu` S2 / P2 | gallery header with Back to main menu |
| `screenshots/03-menu-after-gallery-back.png` | `PTU-menu` S2 / P2 | menu after C4 |
| `screenshots/04-settings-from-menu.png` | `PTU-menu` S3 / P3 | settings opened from the menu |
| `screenshots/05-menu-after-settings-back.png` | `PTU-menu` S3 / P3 | menu after settings Back |
| `screenshots/06-gallery-settings-back.png` | AC — gallery Settings | gallery after its own settings Back |
| `screenshots/07-menu-mobile.png` | `PTU-menu` S5 / P5, P6 | mobile framing: Puzzles and Settings, no Exit, stamp |
| `screenshots/08-settings-mobile-from-menu.png` | `PTU-menu` S6 / P3 | mobile settings opened from the menu |
| `screenshots/09-menu-mobile-after-back.png` | `PTU-menu` S6 / P3 | mobile menu after settings Back |
| `screenshots/10-resume-gallery.png` | AC / `NAV.N2` | interrupted session resumes on the gallery |
| `logs/capture.log` | all | capture console, `RESULT pass` |
