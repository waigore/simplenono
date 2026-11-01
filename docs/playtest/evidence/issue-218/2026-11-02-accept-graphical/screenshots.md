# Screenshots — issue #218 graphical acceptance

All seven are from the same build and run as [`manifest.md`](manifest.md), not attached from elsewhere.
The judged states they support are in [`results.md`](results.md).

| Image | Judged state |
|-------|--------------|
| [`p0`](screenshots/p0-gallery-before-play.png) | `UI-gallery` before play: `#000` reads `Not started` (P2 setup) |
| [`p1`](screenshots/p1-puzzle-get-set-ready.png) | `UI-puzzle` during the get-set-ready beat (S2) |
| [`p2`](screenshots/p2-puzzle-marks-allowed.png) | marks allowed after ready (S2) |
| [`p3`](screenshots/p3-puzzle-one-fill-left.png) | 41 of 42 fills staged; still on `UI-puzzle` (S3) |
| [`p4`](screenshots/p4-result-morph-start.png) | `UI-result` mid-morph: the solved fills held, no chrome (US1.1, US1.3) |
| [`p5`](screenshots/p5-result-default.png) | **`S1 Default` — the solved fills at full opacity, `Back to gallery` below** (US1.2, US1.5) |
| [`p6`](screenshots/p6-gallery-after-result-back.png) | after C1: `#000` `Done`, `Completed 1 / 200` (S4, P1, P2) |

The failing state this defect was filed for is [`#95 p10`](../../issue-95/2026-11-02-accept-graphical/screenshots/p10-result-default.png),
blank paper at the same `S1 Default`. `p5` is that same state after the fix.
