# Playtest run — issue #156 (graphical)

- **Issue:** #156 Reopened in-progress puzzle allows marks during get-set-ready (`type:defect`)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@3f402fe` (includes #156 `5196281` and the S1–S5 seams `3f402fe`),
  Godot 4.7.2.stable; session `issue-156-capture`
- **Coverage mode:** `full` · **Run type:** graphical (Metal 4.0, 900×1200, viewport images)
- **Level:** Design + `UI-puzzle` US1.7

## Scope

The deliverable is PR [#160](https://github.com/waigore/simplenono/pull/160) (`8adb154`, squash
`5196281`); its code is unchanged on this build. `PTD-ready-and-marks` S1–S4 are the steps this fix
can move. `PTU-play-puzzle` is not runnable (no gallery or result screen, #94/#95).

This run re-runs the protocols on `main@3f402fe`; the previous headless run judged `main@59872bd`
([record](../2026-11-02-accept/manifest.md)). `#169` supplied the S1–S5 seams
[`verification.md`](../../../../../specs/technical/verification.md) H1 requires, and `#110`
(`dc7505d`) changed the S2 chrome since, so the criteria are re-judged here.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-ready-and-marks` S1 | **pass** | fresh `S2`, tap leaves the cell clear, `0:00` |
| `PTD-ready-and-marks` S2 | **pass** | fill → clear → cross apply; `DBG.2` returns a payload |
| `PTD-ready-and-marks` S3 | **pass** | wrong fill stays, attempt stays `S1`, not solved |
| `PTD-ready-and-marks` S4 | **pass** | `DBG.1` pause: `S3`, tap ignored, `0:22` frozen; resume restores marks |
| `PTD-ready-and-marks` P1–P3 | **pass** | no `F1` / `F2` trigger |
| `UI-puzzle` US1.7 reopened | **pass** | `S2`, `C2` `IGNORE`, stored fill, `0:18`; then `S1`, `STOP`, `0:22` |
| Defect AC1–AC8 | **pass** | graphical AC1–AC5/7/8; model probe AC1–AC8 |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-fresh-ready-blocked.png) | fresh get-set-ready, blocked, `0:00` |
| [`01`](screenshots/01-ready-fill-clear-cross.png) | Ready after fill → clear → cross |
| [`02`](screenshots/02-wrong-fill-playable.png) | wrong fill, no fail state |
| [`03`](screenshots/03-reopened-ready-blocked.png) | reopened `S2`, stored fill, `0:18` |
| [`04`](screenshots/04-reopened-blocked-mark-attempt.png) | tap during the beat, nothing changes |
| [`05`](screenshots/05-after-beat-marks-allowed.png) | after the beat, fill applies, `0:22` |
| [`06`](screenshots/06-paused-mark-blocked.png) | paused, tap ignored, `0:22` frozen |
| [`07`](screenshots/07-resumed-mark-applied.png) | resumed, fill applies, `0:22` |

`06` is pixel-identical to `05`: no pause chrome exists yet (#96), so `TEL event=pause` and the
frozen `0:22` are the judged state. `03`/`04` are identical because the blocked mark changes
nothing.

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes, criteria | [`notes.md`](notes.md), [`criteria.md`](criteria.md) | present |
| Capture probe, run once and removed from `game/` | [`probe/probe_capture_156.gd`](probe/probe_capture_156.gd) | present |
| Capture console (`TEL.*`, every `capture: PASS`) | [`logs/capture-console.log`](logs/capture-console.log) | 85 lines, exit 0 |
| Shipped suite | [`logs/gut-suite.log`](logs/gut-suite.log) | 11 scripts, 139/139, 29 204 asserts, exit 0 |
| Model probe (headless) | [`logs/probe-model.log`](logs/probe-model.log) | 4/4, 47 asserts, exit 0 |

Stored logs are the native GUT runs stripped of ANSI; every test line and exit status is kept.

## Quality evaluator

`resume-after-failure` (I10, deterministic) — latest verify-time record:
[`docs/quality/evidence/issue-156/2026-11-02T000000Z/manifest.md`](../../../../quality/evidence/issue-156/2026-11-02T000000Z/manifest.md),
**pass**. The deliverable code is unchanged and this run re-observed the reopen result it cites.

## Reproduce

See [`notes.md`](notes.md#reproduce).
