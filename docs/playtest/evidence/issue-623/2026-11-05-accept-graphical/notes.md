# Notes — issue #623 graphical acceptance (`PTU-menu`)

## What was judged

The probe boots the shipped `shell.tscn` on a fresh `user://` and drives every control
with **real pointer events** (`Input.parse_input_event`, left button), the same path a
player's click takes. After each step it reads the shell's view, the drawn screen, the
control copy, the focus order, the stamp text and its drawn rect/colour, and the palette
of the background. It also seeds an in-progress progress document and boots a second
shell to prove `NAV.N2` still resumes on the gallery.

The stamp was read from a release-shaped `game/release/build_info.json`
(`{"version": "0.1.0", "sha": "7d69040"}`), the document `.github/scripts/export_release.sh`
writes, so the run exercised the release path rather than the dev fallback. The file was
removed after the run.

## Result

`capture: RESULT pass (10 shots, 0 checks failed)`, 52 `capture: PASS` checks, exit 0, no
script errors.

- Cold launch: `UI-menu`, title `simplenono`, Puzzles/Settings/Exit, focus order C1, C2, C3.
- Stamp: `v0.1.0 · 7d69040` at (32, 742) in 1280×800, `DIM` colour, non-empty.
- Puzzles → gallery; C4 Back to main menu → menu.
- Settings from the menu → settings; Back → menu.
- Gallery Settings → settings; Back → gallery (not the menu).
- Exit: C3 quits on desktop (recorded through the shell's `quit_callable` seam).
- Mobile framing: Puzzles and Settings drawn, no Exit, C3 cannot activate, stamp drawn;
  Settings → Back → menu.
- Interrupted resume: a seeded in-progress record boots on the gallery.

## Mobile leg

The host is a desktop Linux build, so the mobile leg sets the screen's own `mobile` field
(the seam the GUT suite uses) and resizes the frame to 390×844. The desktop-only Exit
branch is also covered by `test_exit_is_desktop_only`; no mobile OS build is available on
this host.

## Comparison with the approved mockups

The drawn palette is Paper `#F4F7F8`, Ink `#1B2833`, Rule `#C5D0D6`, and Dim `#6E7F8C`,
matching `MC.menu-mobile` / `MC.menu-desktop` (both `approved` / product owner /
2026-11-05). The action column is at most 420 px, the page gutter stays between the two
mockups' values, Puzzles is the filled action, Settings/Exit are outlined, and the stamp
is bottom-left in muted meta. The gallery header draws C4 beside Settings.
