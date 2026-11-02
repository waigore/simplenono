# Notes — issue #224 acceptance

**Method.** A temporary `SceneTree` probe instantiated the real `shell.tscn` on `main@ce5a677` and
drove both protocols through the real screens and controls: `UI-gallery.C3` → settings toggles → Back
→ reopen; gallery tile `C1` → get-set-ready → every fill but the last → last fill → result Default →
`C1` Back. It also read each visible `Label`/`Button`'s effective family, font size, and the
`FontVariation`'s `tnum` feature, then resized the root to 405×720 and 1920×1080 for the two stacked
captures. The probe file is kept under [`probe/`](probe/probe_accept_224.gd); it was copied into
`game/` for the run and removed after, so no product file changed.

**Judged.**

- `PTU-settings` — P1 and P2 pass; the chrome (title, option labels and hints, toggles, Back) draws the
  catalogued family at T2 = 35 px on this 1400-high window.
- `PTU-play-puzzle` — P1 and P2 pass; no stuck screen on either leg, and the solved tile reads Done.
- `UIS.T1`/`T2` — `Shell.UI_FONT_ASSET_ID` is the catalogued `fonts/outfit` entry, the shell resolves
  one family, `tnum` is on, clue labels are the family at half the laid-out cell side (20 px here, the
  7 px floor untouched), and chrome is 18 px at a 720 frame and 27 px at a 1080 frame.

**Not judged here.** Whether the glyphs of the shipped face are pleasing, and whether type fits with
no clipping at the two stacked heights (criterion 5). The `llm-judge` mode cannot read images with this
agent's model, so the criterion-5 captures from the implementation run
([`issue-224/2026-11-02-implement/screenshots/`](../2026-11-02-implement/screenshots.md), with its
layout audit) are cited for that criterion, and this run adds stacked gallery captures at the same
heights.

**Non-blocking marks.** The probe used the local progress file for gallery state, so tiles read fresh
before the run; that is a state choice, not a protocol fail.
