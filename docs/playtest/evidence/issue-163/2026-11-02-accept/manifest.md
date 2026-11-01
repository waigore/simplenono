# Acceptance run — issue #163

- **Issue:** #163 Verification seams S1–S5 (`type:task`, parent #91)
- **Run id:** `2026-11-02-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build:** `main@3cab7de` with `3f402fe` (PR #169, S1–S5) and `fdcb298` (PR #185, severity log). Re-checked on `cd08f79`: seam sources and the flag gate unchanged, suite 170/170 ([log](logs/gut-suite-cd08f79.log)).
- **Coverage:** `full` · **Run type:** headless checks plus graphical capture (900×1200). Sessions `issue-163-capture` and `accept163`.

## Scope

No playtest protocol is in scope. The deliverable is the playtest tooling itself ([`verification.md`](../../../../../specs/technical/verification.md) S1–S5, [`tools.md`](../../../../../specs/playtest/tools.md) `DBG.1`–`DBG.4`, `TEL.1`–`TEL.5`, `SIT.3`), debug-build-only, and the issue fixes that it changes no gameplay, rule, progress-file, or player-screen behaviour. The graphical capture serves AC 2 (S4 "graphical") and AC 6 (visible overlay); it is not a protocol run.

## Results

| Criterion | Outcome | Note |
|-----------|---------|------|
| H1 / H2 — one flag; off unreachable | **pass** | flag-off test; boot exit 0 with 0 `TEL`/`SEV` |
| S1 / `DBG.1` halt-continue (O4/O5) | **pass** | paused, marks blocked, elapsed frozen; resume restores |
| S1 / `DBG.3` open in place (O1, `G3`) | **pass** | `pack-000` → `pack-007`; unknown id changes nothing |
| S2 / `DBG.2` inspect | **pass** | three schemata; before/after unchanged; no record invented |
| S3 / `DBG.4` overlay | **pass** | `story: L-solve.PS1.1, US1.7` |
| S4 / `TEL.1`–`TEL.5` | **pass** | 6 capture events with five fields; 405 `TEL` headless and graphical |
| S5 / `SIT.3` dump | **pass** | `state-pack-042.json`; exit 1 unknown, exit 2 flag off |
| Tests / format / lint | **pass** | 151/151; `gdformat` 61 unchanged; `gdlint` clean; spec lint 0 errors |
| No gameplay/screen change; no new ID | **pass** | `specs` diff empty; seam sources identical at `3cab7de`; S6 stays #105 |

Detail: [`criteria.md`](criteria.md).

## Screenshots

| Image | State |
|-------|-------|
| [`00`](screenshots/00-flag-on-home-overlay.png) | flag on, home, overlay with both story ids (S3) |
| [`01`](screenshots/01-paused-session.png) | `pack-000` halted, screen `S3` (S1) |
| [`02`](screenshots/02-resumed-session.png) | continued, screen `S1` (S1) |
| [`03`](screenshots/03-opened-in-place.png) | `pack-007` opened in place (S1) |
| [`04`](screenshots/04-unknown-id-unchanged.png) | after `G3` refusal, same id and attempt |

`01`/`02` are identical because pause chrome is #96's; `03`/`04` because `G3` changes nothing. The judged state is in the seam reads ([capture console](logs/capture-console.log)).

## Paths

| Artifact | Path |
|----------|------|
| Notes / criteria | [`notes.md`](notes.md), [`criteria.md`](criteria.md) |
| Capture probe (run once, removed from `game/`) | [`probe/probe_capture_163.gd`](probe/probe_capture_163.gd) |
| Capture console (60 PASS, 5 shots, 6 events) | [`logs/capture-console.log`](logs/capture-console.log) |
| S2 payloads | [`logs/inspect-before.json`](logs/inspect-before.json), [`logs/inspect-paused.json`](logs/inspect-paused.json) |
| S4 events | [`logs/telemetry-events.ndjson`](logs/telemetry-events.ndjson); [`paint-headless.log`](logs/paint-headless.log); [`paint-graphical.log`](logs/paint-graphical.log) |
| S5 dump and error codes | [`logs/state-pack-042.json`](logs/state-pack-042.json); [`s5-dump.log`](logs/s5-dump.log); [`s5-unknown-id.log`](logs/s5-unknown-id.log); [`s5-flag-off.log`](logs/s5-flag-off.log) |
| Boots and suite | [`flag-off-boot.log`](logs/flag-off-boot.log); [`flag-on-boot.log`](logs/flag-on-boot.log); [`gut-suite.log`](logs/gut-suite.log) |
