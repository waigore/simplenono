# Results — issue #95 graphical acceptance

Protocol outcomes for both in-scope protocols; the run's setup and scope are in
[`manifest.md`](manifest.md).

`PTU-settings` passed **all** checks. `PTU-play-puzzle` passed `P1` and failed `P2`'s judged state: the
result screen's Default stage renders blank because this build ships no pictures.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-settings` S1 → `UI-gallery.C3` | **pass** | the gallery's `Settings` button opens `UI-settings` (`NAV.T2`) |
| `PTU-settings` S2 → `UI-settings.C1`/`C2` | **pass** | each toggle flips its `SCH-preferences` flag and the label (`On`/`Off`) |
| `PTU-settings` S3 → `UI-settings.C3` | **pass** | Back returns to `UI-gallery`; reopening shows the changed values still set |
| `PTU-settings` P1 / P2 | **pass** | gallery → settings → Back → gallery works; Haptics stayed `Off` and Mute music stayed `On` across reopen |
| `PTU-settings` F1 / F2 | **no fail** | neither fail condition occurred |
| `UI-settings` US1.1 / US1.2 / US1.3 | **pass** | defaults `Haptics On` / `Mute music Off`; C1 → `Off`; C2 → `On` |
| `PTU-play-puzzle` S1 → gallery tile C1 | **pass** | the tile opens `UI-puzzle` for `pack-000` (`NAV.T1`) |
| `PTU-play-puzzle` S2 → get-set-ready | **pass** | the beat blocks marks, then marks are allowed |
| `PTU-play-puzzle` S3 → last fill | **pass** | a partial grid stays on `UI-puzzle` (US1.4b); the last fill opens `UI-result` (`NAV.T4`) |
| `PTU-play-puzzle` S4 → `UI-result.C1` | **pass** | Back returns to `UI-gallery` (`NAV.T5`) |
| `PTU-play-puzzle` P1 | **pass** | gallery → puzzle → result → gallery completes with no stuck screen; the morph spent 560.8 ms over 69 real frames (2 × 300 ms) |
| `PTU-play-puzzle` P2 | **FAIL** | see [`failure.md`](failure.md): the result's judged Default state is blank, and the gallery shows the solved puzzle `Done` |
| `UI-result` US1.1 | **pass** | the morph runs on open and no control is offered during it |
| `UI-result` US1.2 | **FAIL** | `S1 Default` shows **no picture at all** — the reveal ends on empty paper |
| `UI-result` US1.5b | **pass** | C1 is unavailable while morphing |
| `NAV` US1.1 / US1.4 / US1.5 / T1 / T4 / T5 | **pass** | as the `PTU-play-puzzle` rows above |
| `NAV` US1.2 / US1.6 / T2 / T6 | **pass** | as the `PTU-settings` rows above |
