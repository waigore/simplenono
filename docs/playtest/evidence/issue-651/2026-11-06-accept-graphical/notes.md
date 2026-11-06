# Notes — issue #651, `2026-11-06-accept-graphical`

## What was judged

The shipped screens, driven through the real controls under Xvfb at the approved
`MC.settings-mobile` device frame (390×844) and `MC.settings-desktop` frame
(1280×800), with a fresh `user://` per phase:

- `PTU-settings` S1–S3 / P1 / P2 — gallery C3 opens settings, C3 Back returns, the
  toggles stick on reopen, and a hint assist survives a force-quit + relaunch.
- `PTU-settings` S6 / P5 — a puzzle paused into settings, a hint assist enabled, and
  Back: the open attempt is voided for hint-free.
- `US1.8` — the three hint-assist toggles persist and prove C5–C7.
- `MC.settings-mobile` / `MC.settings-desktop` — labels, hint lines, default-off
  values, and row order.

The toggles went through the screen's own buttons (`C1`, `C5`, `C6`, `C7`, `C3`), the
same `pressed` path a player uses. The relaunch phase is a separate Godot process on
the same `HOME`, so `user://hint-prefs.cfg` is read from disk, not from memory.

## Persistence readings

| Phase | Check | Observed |
|-------|-------|----------|
| first | defaults | haptics On, mute Off, C5/C6/C7 Off |
| first | after C1 + C5 | haptics Off, single-line On; store holds single-line on |
| first | Back → reopen | haptics Off, single-line On |
| relaunch | fresh process | single-line On, multi-line Off, line-fillable Off; haptics back to On (session-only) |
| void | fresh attempt | `hint_free_eligible()` true, no assist latched |
| void | C6 on while paused | `hint_free_eligible()` false, `hint_assist_enabled_during_attempt()` true |
| void | Back to puzzle | still ineligible; the void survives the return |

## Row order and copy

`focus_controls()` on this desktop build is C1 Haptics, C2 Mute music, C5 Single-line
hint, C6 Multi-line hint, C7 Line-fillable hint, C3 Back. C4 Orientation is absent
because `OrientationLock.mobile` is false on Linux (`UI-settings` R1: desktop shows
C1, C2, C5–C7). The labels and hint lines match the approved mockups' hint rows.

## Non-blocking observations

- **Desktop haptics/mute hint lines.** `MC.settings-desktop` carries
  `Default on · mobile fill/cross` and `BGM only · SFX stay on · default off`, while
  the screen uses the mobile mockup's shorter `Default on` / `BGM only · SFX on` on
  both builds. This predates #651 (the desktop mockup line is from #36 and the
  constants from #202/#216); it is outside this deliverable's C5–C7 scope and is not
  a protocol fail. Flagged for the settings screen's owner.
- **Mobile-only steps.** S4–S5 / P3–P4 need a phone or tablet (situational tool). This
  run is a desktop build, so they are not applicable; the #95 settings acceptance run
  took the same position.

## Harness caveats (probe-side, not product)

- **Resume start.** The shell opens on the gallery when any pack entry is in progress
  (`NAV.N1/N2`). Each phase used a fresh `HOME`, so the cold start is the menu.
- **Frame vs platform.** 390×844 is the mobile mockup's frame, but the build is a
  desktop platform, so C4 stays hidden. The mobile-frame shots show the desktop
  control set at that width; the mobile-only C4 row is not exercised here.

## Hygiene

- The probe was copied to `game/probe_accept_651.gd` for the run and removed after;
  `game/` was verified unchanged before the evidence branch.
- Local user data written by the run lives under the temporary `HOME` dirs; it is not
  committed. Screenshots and logs are on the wiki, not in git.
