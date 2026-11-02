# Screenshots — issue #95 graphical acceptance, rerun after the #218 fix

All twelve are from the same build and run as [`manifest.md`](manifest.md) (`main@e1de7a4`), not attached
from elsewhere. The judged states they support are in [`results.md`](results.md).

| Image | Judged state |
|-------|--------------|
| [`p0`](screenshots/p0-settings-default.png) | `UI-settings` on open: Haptics `On`, Mute music `Off` (US1.1) |
| [`p1`](screenshots/p1-settings-before-toggle.png) | the same defaults immediately before `S2` |
| [`p2`](screenshots/p2-settings-after-toggle.png) | after C1 and C2: Haptics `Off`, Mute music `On` |
| [`p3`](screenshots/p3-gallery-after-settings-back.png) | Back on `C3` returned to `UI-gallery` |
| [`p4`](screenshots/p4-settings-reopened-stuck.png) | settings reopened: Haptics `Off`, Mute music `On` — the values stuck |
| [`p5`](screenshots/p5-gallery-before-play.png) | `#000` reads `Not started` before play |
| [`p6`](screenshots/p6-puzzle-get-set-ready.png) | `UI-puzzle` during the get-set-ready beat |
| [`p7`](screenshots/p7-puzzle-marks-allowed.png) | marks allowed after ready |
| [`p8`](screenshots/p8-puzzle-one-fill-left.png) | mid-solve grid, 41 fills staged; still on `UI-puzzle` |
| [`p9`](screenshots/p9-result-morph-start.png) | `UI-result` mid-morph start: the solved fills, no chrome |
| [`p10`](screenshots/p10-result-default.png) | **`S1 Default` — the solved fills visible, `Back to gallery` shown**; this is the state that was blank before #218 |
| [`p11`](screenshots/p11-gallery-after-result-back.png) | after C1: `#000` `Done`, `Completed 1 / 200` |

## How `p10` was judged without a human eye on it

The reveal box covers x 32–868, y 32–392. Inside it, `p10` is 40.35% ink (`#1b2833` fills) on `#f4f7f8`
paper, 3.94% rule lines — 42 filled cells, matching `pack-000`'s solution. Compared pixel-for-pixel with
`p9`, the only differing region is x 32–867, y 408–468, the Back-chrome band, so the reveal content and the
chrome change exactly as `UI-result` R1/S1 and US1.2 require.

Some pairs are byte-identical by design: `p0`/`p1` (defaults before the toggle), `p2`/`p4` (the toggled
values after reopen), `p3`/`p5` (the gallery before play and after the settings round trip), and
`p7`/`p8` (`marks_allowed()` is not drawn). Identical images are the correct result for those pairs.
