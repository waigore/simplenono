# Screenshots — issue #95 graphical acceptance

All twelve are from the same build and run as [`manifest.md`](manifest.md), not attached from elsewhere.
The judged states they support are in [`results.md`](results.md).

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
| [`p8`](screenshots/p8-puzzle-one-fill-left.png) | mid-solve grid; still on `UI-puzzle` |
| [`p9`](screenshots/p9-result-morph-start.png) | `UI-result` mid-morph: the solved fills, no chrome |
| [`p10`](screenshots/p10-result-default.png) | **`S1 Default` — blank; the judged failure** |
| [`p11`](screenshots/p11-gallery-after-result-back.png) | after C1: `#000` `Done`, `Completed 1 / 200` |

Why some pairs are byte-identical is explained in [`notes.md`](notes.md#non-blocking-marks).
