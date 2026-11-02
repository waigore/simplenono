# Screenshots — issue #224 AC5

Real `root.get_texture()` captures from one graphical run of the branch build under
`xvfb-run` (Godot 4.7.2, Vulkan / llvmpipe). None is edited. The screens adopt the
resolved catalogued family and `UIS.T2` = round(frame height / 40), so chrome is 18 px
at the 720-high frame and 27 px at the 1080-high frame.

| File | Size | What it shows |
|------|------|---------------|
| [`gallery-405x720.png`](screenshots/gallery-405x720.png) | 405×720 | Gallery chrome, progress block, and two-column tiles at T2 = 18 px |
| [`gallery-1920x1080.png`](screenshots/gallery-1920x1080.png) | 1920×1080 | Gallery at four columns, T2 = 27 px |
| [`puzzle-405x720.png`](screenshots/puzzle-405x720.png) | 405×720 | Puzzle chrome row, board clue labels (T1), and the three tools at T2 = 18 px |
| [`puzzle-1920x1080.png`](screenshots/puzzle-1920x1080.png) | 1920×1080 | The same puzzle regions at T2 = 27 px |
| [`result-405x720.png`](screenshots/result-405x720.png) | 405×720 | Result screen with the Back control at T2 = 18 px |
| [`result-1920x1080.png`](screenshots/result-1920x1080.png) | 1920×1080 | Result screen at T2 = 27 px |
| [`settings-405x720.png`](screenshots/settings-405x720.png) | 405×720 | Settings title, option labels and hints, toggles, and Back at T2 = 18 px |
| [`settings-1920x1080.png`](screenshots/settings-1920x1080.png) | 1920×1080 | Settings at T2 = 27 px |

The capture run also audited each screen: every visible control kept its minimum size
and no visible text control overlapped another. The raw output is
[`logs/layout-audit.log`](logs/layout-audit.log) (no `AUDIT` lines).
