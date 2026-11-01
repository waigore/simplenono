# Paths — issue #107 graphical run

[Manifest](manifest.md) · [`notes.md`](notes.md) · [`criteria.md`](criteria.md) ·
[`falsification.md`](falsification.md)

| Artifact | Path | State |
|----------|------|-------|
| Capture probe, run once and removed from `game/` | [`probe/probe_capture_107.gd`](probe/probe_capture_107.gd) | present |
| Capture console (`TEL.*`, every `capture: PASS`) | [`logs/capture-console.log`](logs/capture-console.log) | exit 0 |
| Shipped suite | [`logs/gut-suite.log`](logs/gut-suite.log) | 11 scripts, 139/139, 29 204 asserts, exit 0 |
| Fixture independence | [`logs/fixture-check.log`](logs/fixture-check.log) | runs from F5 equal F3/F4; test literals equal the fixture |
| Falsification — columns from `row_clues` | [`logs/falsify-columns-from-rows.log`](logs/falsify-columns-from-rows.log) | 13 failing, exit 1 |
| Falsification — short list padded | [`logs/falsify-padded-lists.log`](logs/falsify-padded-lists.log) | 3 failing, exit 1 |

Logs are the native runs stripped of ANSI, with every test line and exit status kept. The suite
counts are read from the report, not only the exit code: GUT logs an unparseable script as
skipped and still exits 0.
