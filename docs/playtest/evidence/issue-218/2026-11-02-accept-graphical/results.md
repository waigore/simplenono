# Results — issue #218 acceptance playtest

Run: [`2026-11-02-accept-graphical`](manifest.md), build `main@8cfb263`, Godot 4.7.2, graphical.
Probe log: [`logs/probe-graphical.log`](logs/probe-graphical.log) — 28 checks, 0 failures.

This build ships no stored pictures: `assets/manifest.json` holds five audio entries and neither
`pack-000` picture id. Every row below therefore judges the missing-picture path the defect is about.

## PTU-play-puzzle

| Step / row | What was observed | Outcome | Screenshot |
|------------|-------------------|---------|------------|
| S1 | Started on `UI-gallery`; tile C1 opened `UI-puzzle` for `pack-000`, reading `Not started` before the run | pass | [`p0`](screenshots/p0-gallery-before-play.png) |
| S2 | The get-set-ready beat blocked marks first, then allowed them | pass | [`p1`](screenshots/p1-puzzle-get-set-ready.png), [`p2`](screenshots/p2-puzzle-marks-allowed.png) |
| S3 | Staged all but the last fill (still on `UI-puzzle`); the last fill stilled `END.W1` and opened `UI-result` | pass | [`p3`](screenshots/p3-puzzle-one-fill-left.png), [`p4`](screenshots/p4-result-morph-start.png) |
| S4 | After the morph, `UI-result.C1` Back returned to `UI-gallery` | pass | [`p6`](screenshots/p6-gallery-after-result-back.png) |
| **P1** | Gallery → puzzle → result → gallery completed with no stuck screen | **pass** | [`p6`](screenshots/p6-gallery-after-result-back.png) |
| **P2** | `pack-000` read `Done` after the solve; gallery completion moved past zero | **pass** | [`p6`](screenshots/p6-gallery-after-result-back.png) |

## UI-result stories

| Story | What was observed | Outcome | Screenshot |
|-------|-------------------|---------|------------|
| US1.1 (R1, S2) | The morph opened on `S2` with the solved fills and no controls; it held the fills while the pixel picture was absent | pass | [`p4`](screenshots/p4-result-morph-start.png) |
| US1.2 (R2, S1) | The chain finished at `S1` in 561.2 ms over 69 real frames against `2 × 300` ms; nothing morphed after; C1 read `Back to gallery` and was available | pass | [`p5`](screenshots/p5-result-default.png) |
| US1.2b (C1) | C1 opened `UI-gallery` | pass | [`p6`](screenshots/p6-gallery-after-result-back.png) |
| US1.3 (C1) | C1 was unavailable for the whole morph | pass | [`p4`](screenshots/p4-result-morph-start.png) |
| US1.4 (R1, S3) | With the generated picture absent, `S3` held the same drawable layer rather than fading to nothing | pass | [`p5`](screenshots/p5-result-default.png) |
| **US1.5 (R1, S1)** | At `S1 Default` one drawable layer was visible: the solved fills at full opacity (`fill_count=42`), not the absent picture layers. **No frame between `S2` and `S1` was empty (0 of 69).** | **pass** | [`p5`](screenshots/p5-result-default.png) |

## The regression this defect reported

Before the fix, `#95`'s graphical run recorded [`p10-result-default`](../../issue-95/2026-11-02-accept-graphical/screenshots/p10-result-default.png)
as blank paper with only `Back to gallery`. Comparing this run's [`p5`](screenshots/p5-result-default.png) against
it: the same `S1 Default`, the same C1, and the picture is there now — the solved fills, which is the best shipped
layer this build has.
