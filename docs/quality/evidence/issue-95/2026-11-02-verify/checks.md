# Independent checks — issue #95

Run on `94e6c55` (the deliverable commit; `main` HEAD at the time), Godot 4.7.2, macOS, headless.

## Commands and results

| Check | Command | Result |
|-------|---------|--------|
| Unit tests | `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` | 19 scripts, 215 tests, 215 passing, 29,956 asserts, exit 0 |
| Format | `gdformat --check game` | 80 files unchanged |
| Lint | `gdlint game` | Success: no problems |
| PR checks | `gh pr checks 202`, `gh pr checks 208` | Code lint, Unit tests, Coverage, Spec lint, PR hygiene, Integration harness all pass |
| Protocols | five `run_protocol.gd` runs into this folder | see `integration/results.md` |

## Harness gap

Only `paint` samples frames (`sample_start`/`sample_stop`). `navigate` drives the
result reveal but writes an empty `navigate-samples.ndjson`, so I1/I2 cannot observe the
reveal's frame budget. The `frame-time` and `hitch-bound` rows are therefore blocked in
[`manifest.md`](manifest.md). This is a harness gap, not a product defect.

## Product behavior probe

The reveal clock finding in [`rationale.md`](rationale.md) came from a temporary GUT
test against the real `shell.tscn`; it was deleted before this record was committed, so
no product code differs from `94e6c55`.
