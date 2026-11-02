## Code review: Pass

**Target:** PR #320 (merged as `6884a36`; diff `16d03f2..99dcd4e`)

### Findings

- `[CONT]` `suggestion` — `game/presentation/confirm_overlay.gd:47` uses one `OVERLAY_ALPHA` (0.28) for both
  widths, while the approved mobile mockup dims at 35%; the mobile action buttons also use the 44 px desktop
  height where the mockup asks for 48. Non-material, but worth aligning if the overlay is touched again.
- `[SRP]` `suggestion` — `GalleryScreen.present_reset_confirm` repeats the `reset_allowed()` check already
  performed by the C2 path it answers. It is the S1 entry guard, not a second O7, so it stays.
- `[DIP]` `suggestion` — `ConfirmOverlay` reads `PresentationPalette` constants directly, matching the other
  presentation scripts; no new dependency seam is introduced.

### Checks

- `gdformat --check game` — pass (85 files unchanged)
- `gdlint game` — pass
- `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` — 266/266 tests, 29,839 asserts
- CI `Code lint`, `Unit tests`, `Coverage` — success on PR #320

### Notes

- The overlay owns show/confirm/cancel and drawing, the gallery owns the S1/S6 presentation state and the
  behind-it guard, and the shell owns S2-S6 and the single `Pack.reset` call. That split matches the sequence
  and keeps O7 in one place.
- No keyboard map was added; Enter/Space and Escape routing remain #312's, as the body requires.
- `game/addons/` skipped; `specs/playtest/story-rows.md` is non-code.
