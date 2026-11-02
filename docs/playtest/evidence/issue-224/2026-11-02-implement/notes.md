# Notes — issue #224 AC5

**Method.** A temporary `SceneTree` script instantiated the real `gallery.tscn`,
`puzzle.tscn`, `result.tscn`, and `settings.tscn`, injected `UiTheme` built from the
production manifest and `Shell.UI_FONT_ASSET_ID`, first presented each screen (the
puzzle opened `pack-000` and finished the get-set-ready beat; the result finished its
morph), then set the window to 405×720 and 1920×1080 and saved `root.get_texture()`.
The script was deleted after the run; it is not part of the deliverable.

**Audit.** For each captured screen the run checked every visible `Control` against
`get_minimum_size()` (a squeezed control would clip or overflow) and checked every pair
of visible `Label`/`Button` controls for rect intersections, skipping ancestor pairs.
Zero findings at both frame heights; see [logs/layout-audit.log](logs/layout-audit.log).

**Non-blocking marks.** The gallery screenshots use an unseeded local progress file, so
tiles read as fresh. That is a state choice, not a defect: AC5 judges chrome type fit,
and the tile metadata also uses T2 (asserted by `test_ui_theme.gd`).
