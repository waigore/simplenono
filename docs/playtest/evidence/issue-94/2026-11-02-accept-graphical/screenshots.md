# Screenshots — issue #94 graphical acceptance

All five are real `root.get_texture()` captures from the same build and run as the probe log
(`main@6f7264f`). None is edited.

| File | Size | What it shows | Judges |
|------|------|---------------|--------|
| [`00-g1-gallery-seeded.png`](screenshots/00-g1-gallery-seeded.png) | 390×1200 | The gallery on the seeded pack: `Completed 48 / 200`, `#001 Done · Best 4:13` with Reset, `#002 In progress` without a best and with Reset, `#003 Not started` with no Reset, generic placeholder art, Settings drawn, two columns | `UI-gallery` US1.1–US1.6b, S1 |
| [`01-g2-gallery-c2-fired-no-confirm.png`](screenshots/01-g2-gallery-c2-fired-no-confirm.png) | 390×1200 | After `C2` fired on `#000`: the gallery stays Default and no confirm surface appears (that is #96's) | `SEQ reset` S1, `PTU-gallery-reset` boundary |
| [`02-g3-gallery-after-o7-refresh.png`](screenshots/02-g3-gallery-after-o7-refresh.png) | 390×1200 | After `CTR-pack.O7` + refresh: `#000` reads `Not started`, its Best is gone, Reset is withdrawn, count `Completed 47 / 200` | `SEQ reset` S5, `J-gallery-reset` N2 |
| [`03-g4-gallery-after-leave-reread.png`](screenshots/03-g4-gallery-after-leave-reread.png) | 390×1200 | After opening `#002`, resetting it, and leaving: `#002` reads `Not started`, count stays `Completed 47 / 200` | `SEQ reset` S5 via the leave leg |
| [`04-g5-gallery-desktop.png`](screenshots/04-g5-gallery-desktop.png) | 1400×800 | The desktop layout: four columns, square picture regions | `UI-gallery` S1, R2 |

The protocol's wanted "confirm dialog" shot does not exist: this build has no `EX.confirm`
(#96). The protocol's "gallery tile after Confirm" shot is covered by `02`/`03`, captured
through `O7` rather than through the absent Confirm.
