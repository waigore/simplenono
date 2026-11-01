# Criteria — issue #110 graphical acceptance

One row per acceptance criterion in the issue body. Judged from the screen's contracted reads, taps
through the shipped `MarkInput`, and the saved images.

| Criterion | Verdict | Observation | Evidence |
|-----------|---------|-------------|----------|
| `MC.puzzle` approved before main-tree UI | pass | catalog row still `approved` (review-project-issue, 2026-11-01) | `specs/ux/mockups/catalog.md` |
| US1.1 — Ready, `GS.solve-elapsed` 12, not paused | pass | an in-progress record committed with elapsed 12 is reopened; S2 already shows `0:12`, Ready keeps `0:12` with no tick; Leave, Settings, and C1–C6 all available | [`00`](screenshots/00-s2-get-set-ready.png), [`01`](screenshots/01-s1-ready-restored-elapsed.png) |
| US1.2 — marks and clues visible, no solution image | pass | restored fill and auto-crosses drawn with row/column clues; recursive `TextureRect` count is 0 (`PER.R4`) | [`01`](screenshots/01-s1-ready-restored-elapsed.png) |
| US1.3 — C3 → C4 → C5 select Fill → Cross → Clear | pass | each button's `pressed` signal changes `selected_tool` and writes the matching mark | [`02`](screenshots/02-fill-applied.png), [`03`](screenshots/03-cross-selected.png), [`04`](screenshots/04-clear-selected.png) |
| US1.5 — Ready, Fill selected, activating a clear cell shows fill | pass | tap at (5,5) through `MarkInput` shows Fill; the cell's rendered mark is `FILL` | [`02`](screenshots/02-fill-applied.png) |
| US1.5b — S2 or Paused leaves cell-marks unchanged | pass | grid signature identical after a tap in S2 and after a tap in S3 | [`00`](screenshots/00-s2-get-set-ready.png), [`05`](screenshots/05-s3-paused.png) |
| US1.6 — C6 opens settings, `GS.paused` true, elapsed frozen | pass at the screen seam, end-to-end deferred | C6 raises `IN.pause`; with the attempt paused the screen is S3, the board is unchanged, and five seconds of `tick()` add nothing. The settings screen and the O4 write are #95/#96, as the passing review scoped | [`05`](screenshots/05-s3-paused.png) |
| US1.7 — just-opened puzzle shows `copy.ready`, marks blocked, C1/C6 available | pass | beat label text is `Ready`; `marks_allowed()` false; Leave/Settings enabled; C3–C5 disabled (matches `MC.puzzle` `state-get-set-ready`) | [`00`](screenshots/00-s2-get-set-ready.png) |
| US1.4 partly — C1 signals leave (`IN.back`); gallery is #94 | pass (intent) | C1 raises `leave_requested`; the shell returns to its home view, which is the current stand-in, not the gallery | [`06`](screenshots/06-after-leave.png) |
| Layout, palette, structure match approved `MC.puzzle` | pass | R1 chrome (Leave, Settings, elapsed), R2 board with clue bars and cells, R3 Fill/Cross/Clear; S1/S2/S3 present; `copy.*` strings `Leave`, `Settings`, `Fill`, `Cross`, `Clear`, `Ready`, `{m}:{ss}` | all images |

## Deferred (owned elsewhere, not #110)

- `UI-gallery` route after C1 — #94.
- `UI-result` route on solve and the pause/settings screen — #95.
- `CTR-attempt` O4 pause write and resume on Back — #96.
