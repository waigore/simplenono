# Results — issue #95 graphical acceptance, rerun after the #218 fix

Protocol outcomes for both in-scope protocols on `main@e1de7a4`; setup and scope are in
[`manifest.md`](manifest.md).

Both protocols pass. The `p10` judged state that failed on `a0e6e3a` now shows the solved fills.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-settings` S1 → `UI-gallery.C3` | **pass** | the gallery's `Settings` button opens `UI-settings` (`NAV.T2`) |
| `PTU-settings` S2 → `UI-settings.C1`/`C2` | **pass** | each toggle flips its `SCH-preferences` flag and its label (`On`/`Off`) |
| `PTU-settings` S3 → `UI-settings.C3` | **pass** | Back returns to `UI-gallery`; reopening shows the changed values still set |
| `PTU-settings` P1 / P2 | **pass** | gallery → settings → Back → gallery works; Haptics stayed `Off`, Mute music stayed `On` |
| `PTU-settings` F1 / F2 | **no fail** | neither fail condition occurred |
| `UI-settings` US1.1 / US1.2 / US1.3 | **pass** | defaults `Haptics On` / `Mute music Off`; C1 → `Off`; C2 → `On` |
| `J-settings` US1.1 / US1.2 (`S1`–`S3`, `B1`) | **pass** | the haptics path and the mute branch both complete and return to the gallery |
| `PTU-play-puzzle` S1 → gallery tile C1 | **pass** | the tile opens `UI-puzzle` for `pack-000` (`NAV.T1`) |
| `PTU-play-puzzle` S2 → get-set-ready | **pass** | the beat blocks marks, then marks are allowed |
| `PTU-play-puzzle` S3 → last fill | **pass** | a partial grid (41 staged fills) stays on `UI-puzzle` (US1.4b); the last fill opens `UI-result` (`NAV.T4`) |
| `PTU-play-puzzle` S4 → `UI-result.C1` | **pass** | Back returns to `UI-gallery` (`NAV.T5`) |
| `PTU-play-puzzle` P1 | **pass** | gallery → puzzle → result → gallery completes with no stuck screen |
| `PTU-play-puzzle` P2 | **pass** | `#000` reads `Not started` before play and `Done` after; gallery completion moved past zero |
| `UI-result` US1.1 / S2 | **pass** | the morph runs on open and no control is offered during it |
| `UI-result` US1.2 / S1 | **pass** | `S1 Default` shows the best shipped layer — the solved fills, 42 fills on paper — and C1 is available |
| `UI-result` US1.5 / R1 | **pass** | with both pictures absent the reveal holds the solved fills; no blank frame (the #218 case) |
| `UI-result` US1.5b | **pass** | C1 is unavailable while morphing |
| `NAV` US1.1 / US1.4 / US1.4b / US1.5 / US1.5b / T1 / T4 / T5 | **pass** | as the `PTU-play-puzzle` rows above |
| `NAV` US1.2 / US1.6 / T2 / T6 | **pass** | as the `PTU-settings` rows above |
| `NAV` US1.7 / US1.8 / T7 / T8 | **pass** | pause → settings → resume, proved by `test_settings_navigation.gd` on this tree (the probe does not drive the pause leg) |
| `NAV` US1.9 / N1 | **pass** | `app-start` harness protocol: cold launch lands on the interactive gallery |
| `ACT-player` US1.1 / US1.2 / US1.4 | **pass** | gallery, puzzle, and settings controls each produce their stated result in this run |
| `ACT-player` US1.3 / C3 | **pass** | the result's C1 through the real control returns to the gallery |
| `ACT-player` US1.5 / K1 | **pass** | no pack-editor or online-account control exists on any formalised screen |

## Non-protocol checks

| Check | Result | Evidence |
|-------|--------|----------|
| GUT suite, whole tree | **241/241 pass**, 30 302 asserts | [`logs/suite.log`](logs/suite.log) |
| Reveal clock regression tests | **20/20 pass** (incl. `test_one_clock_plays_both_stages_on_real_frames`, `test_a_paused_attempt_freezes_the_morph`) | [`logs/reveal-clock-suite.log`](logs/reveal-clock-suite.log) |
| `frame-time` / `hitch-bound` (re-probed) | pass — `paint` p95 11.67 ms, `navigate` p95 9.09 ms, longest frame 28.00 ms | [`integration/results.md`](integration/results.md) |
| `transition-latency` / `response-delay` / `crash-free` | pass — 360.5 ms longest leg, 28.5 ms longest ack, all four I9 flows across five protocols | [`integration/results.md`](integration/results.md) |
