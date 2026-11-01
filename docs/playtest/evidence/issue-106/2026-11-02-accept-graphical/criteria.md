# Acceptance criteria — issue #106 (graphical run)

Judged on `main@269d854` (Godot 4.7.2.stable), the build that includes the deliverable squash
`eea5f9d`. Criteria derive from the task body and the `E-cell` story it cites. Graphical outcomes come
from this run's [screenshots](screenshots/); value-property outcomes also cite the shipped suite
([`logs/gut-suite.log`](logs/gut-suite.log), 139/139, 29 204 asserts, exit 0).

| ID | Criterion | Source | Outcome | Evidence |
|----|-----------|--------|---------|----------|
| AC1 | Cell states match the story scenarios at PS level: position, fill, clear, cross, blocked mark, auto-cross. | `E-cell` PS1.1–PS1.5 | **pass** | `[01]` auto-crossed rows 0/9; `[02]` fill; `[03]` clear; `[04]` cross; `[00]`/`[06]` blocked; `DBG.2` dump is a 10×10 grid |
| AC2 | Invalid transitions fail: a blocked or paused mark, an out-of-grid position, a repeated mark, and a non-mark value change nothing. | `CTR-attempt` G1, `SEQ-mark` B1–B2, `SCH-mark-grid` I1 | **pass** | `[00]` tap during the beat leaves `CLEAR`; `[06]` paused tap changes nothing; `test_marks_are_blocked_until_allowed`, `test_mark_outside_the_grid_changes_nothing`, `test_applying_the_same_mark_changes_nothing`, `test_unknown_mark_is_rejected` (suite) |
| AC3 | GUT tests pass. | task body | **pass** | [`gut-suite.log`](logs/gut-suite.log) — 11 scripts, 139/139, 29 204 asserts, exit 0 |

`[NN]` is `screenshots/NN-*.png` in this folder.

## Protocol gate

`PTD-ready-and-marks` S1–S4 and P1–P3 **pass**; `PTD-crosses-and-fills` S1–S3 and P1–P2 **pass** on
this build. No `F1` or `F2` trigger. Screenshots for every judged state are in
[`screenshots/`](screenshots/) and named in the [manifest](manifest.md#screenshots). The crossed board
that decides P1–P2 is also dumped at [`logs/state-pack-000.json`](logs/state-pack-000.json)
(`SIT.3`). The only non-player drive path is S4's pause (`DBG.1`), because C6's routing is #96; that
is declared in the [notes](notes.md#how-the-run-was-driven).

## Not decided by this deliverable

- Gallery, result, and settings routing (`UI-gallery` #94, `UI-result` #95, `UI-settings` #96) are
  absent from the build, so no journey-level criterion is judged here.
- Pause chrome and the result screen are later work (#95/#96); their absence is not a failure of this
  task.
- `PTD-crosses-and-fills` S3's "screen change to result" is not applicable until #95; the solve
  transition is judged through `DBG.2` and the recorded `ever_completed`.
