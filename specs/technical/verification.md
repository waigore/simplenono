# Verification

Authoring rules: [`.agents/specs/rules/technical/verification.md`](../../.agents/specs/rules/technical/verification.md).

- **Serves**: The playtest Debug UI and telemetry Must rows ([`DBG.1`](../playtest/tools.md)–`DBG.4`, `TEL.1`–`TEL.5`) and the cited Situational row `SIT.3`
- **Informed by**: [`CMP-shell`](components/shell.md), [`CMP-attempt`](components/attempt.md), [`CTR-attempt`](contracts/attempt.md), [`CTR-pack`](contracts/pack.md), [`persistence.md`](persistence.md), [`quality.md`](../definition/quality.md)
- **ADRs**: [ADR-0001](../adr/decisions/0001-godot-gdscript.md)

## Seams

| ID | Seam | Purpose | How to drive |
|----|------|---------|--------------|
| S1 | Session control | Realizes `DBG.1`, `DBG.3`: halt or continue the session, and open a chosen puzzle id in place | Debug command in a debug build; calls [`CTR-attempt`](contracts/attempt.md) O4, O5, and O1 |
| S2 | State inspect | Realizes `DBG.2`: read the attempt and a progress record, changing nothing | Debug command returns [`SCH-attempt`](schemata/attempt.md), [`SCH-mark-grid`](schemata/mark-grid.md), and [`SCH-progress`](schemata/progress.md) |
| S3 | Story-ID overlay | Realizes `DBG.4`: show active story IDs | Debug toggle on [`CMP-shell`](components/shell.md), fed by the running protocol |
| S4 | Telemetry events | Realizes `TEL.1`–`TEL.5`: open, ready, mark, solved, pause, resume, leave, commit, and reset each emit one event with name, timestamp, session / build id, story id, and outcome | Components emit during play; [`CMP-shell`](components/shell.md) logs one line per event under the debug flag |
| S5 | State dump | Realizes `SIT.3`: write the full board state of the open attempt to a file, so a headless run records evidence without a display | Command-line invocation of a debug build (same debug flag as S1); dumps [`SCH-attempt`](schemata/attempt.md), [`SCH-mark-grid`](schemata/mark-grid.md), and [`SCH-progress`](schemata/progress.md) for the chosen puzzle id to the run folder under `logs/` |
| S6 | Pack load check | Realizes O8 ([`CTR-pack`](contracts/pack.md)) and the [`SCH-puzzle-def`](schemata/puzzle-def.md) invariants I1–I5 without a display | GUT test in `game/test/` calling [`CTR-pack`](contracts/pack.md) O8 with a test pack fixture; asserts accepted and rejected entries |

## Invariants to assert

[`verification/invariants.md`](verification/invariants.md) (I1–I11), including each Applies deterministic quality axis.

## Harness expectations

| ID | Expectation |
|----|-------------|
| H1 | Seams precede playtesting: the first build running a playtest protocol already contains S1–S4. A build without them is not a valid playtest target, and no gate run at `status:pending-acceptance` starts on one. A playtest protocol runs through `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<dir>` |
| H2 | Debug builds only: S1–S3 and S5 sit behind one debug build flag; a release export has none. The harness adds no second flag: a game protocol with the flag off exits nonzero and writes no run folder; only the CI `self-test` runs without it |
| H3 | Telemetry sink: the S4 log is a plain Godot log file, headless and graphical ([ADR-0001](../adr/decisions/0001-godot-gdscript.md)); the harness supplies the session / build id, and the run folder holds the file ([`evidence.md`](../playtest/evidence.md)). Layout is `<run-dir>/integration/results.md`, `samples/` (frame and hitch NDJSON), `logs/` (S4 log and S5 dumps), and `results/` (raw protocol JSON); the harness never writes `manifest.md` |
| H4 | No seed needed: identical setups play identically ([`game-state.md`](../design/game-state.md) Q1). `SIT.1`–`SIT.2` stay unbuilt until a protocol cites one; `SIT.3` is realized by S5 because [`PTD-crosses-and-fills`](../playtest/design/crosses-and-fills.md) cites it |

## Diagram

None — the seams are drive lists, not a graph.
