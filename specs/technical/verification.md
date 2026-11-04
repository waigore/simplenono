# Verification

Authoring rules: [`.agents/specs/rules/technical/verification.md`](../../.agents/specs/rules/technical/verification.md).

- **Serves**: Playtest Debug UI and telemetry Must rows ([`DBG.1`](../playtest/tools.md)–`DBG.4`, `TEL.1`–`TEL.5`) and cited `SIT.3`
- **Informed by**: [`CMP-shell`](components/shell.md), [`CMP-attempt`](components/attempt.md), [`CTR-attempt`](contracts/attempt.md), [`CTR-pack`](contracts/pack.md), [`persistence.md`](persistence.md), [`quality.md`](../definition/quality.md)
- **ADRs**: [ADR-0001](../adr/decisions/0001-godot-gdscript.md)

## Seams

| ID | Seam | Purpose | How to drive |
|----|------|---------|--------------|
| S1 | Session control | Realizes `DBG.1`, `DBG.3`: halt or continue the session, open a chosen puzzle id in place | Debug command in a debug build; calls [`CTR-attempt`](contracts/attempt.md) O4, O5, O1 |
| S2 | State inspect | Realizes `DBG.2`: read attempt and progress record, changing nothing | Debug command returns [`SCH-attempt`](schemata/attempt.md), [`SCH-mark-grid`](schemata/mark-grid.md), [`SCH-progress`](schemata/progress.md) |
| S3 | Story-ID overlay | Realizes `DBG.4`: show active story IDs | Debug toggle on [`CMP-shell`](components/shell.md), fed by the running protocol |
| S4 | Telemetry events | Realizes `TEL.1`–`TEL.5`: open, ready, mark, solved, pause, resume, leave, commit, and reset each emit one event with name, timestamp, session/build id, story id, and outcome | Components emit during play; [`CMP-shell`](components/shell.md) logs one line per event under the debug flag. A Confirm reset emits one ([`reset-telemetry`](sequences/reset-telemetry.md)) |
| S5 | State dump | Realizes `SIT.3`: write the open attempt's full board state to a file, so headless runs record evidence | Debug-build command line (flag as S1); dumps [`SCH-attempt`](schemata/attempt.md), [`SCH-mark-grid`](schemata/mark-grid.md), [`SCH-progress`](schemata/progress.md) for the chosen puzzle id to the run folder under `logs/` |
| S6 | Pack load check | Realizes O8 ([`CTR-pack`](contracts/pack.md)) and the [`SCH-puzzle-def`](schemata/puzzle-def.md) invariants I1–I5 headlessly | GUT test in `game/test/` calling O8 with a pack fixture; asserts accepted and rejected entries |

## Invariants to assert

[`verification/invariants.md`](verification/invariants.md) (I1–I12), including each Applies deterministic axis.

## Harness expectations

| ID | Expectation |
|----|-------------|
| H1 | Seams precede playtesting: the first build running a playtest protocol already contains S1–S4. A build without them is not a valid playtest target, and no gate run at `status:pending-acceptance` starts on one. A playtest protocol runs `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<dir>` |
| H2 | Debug builds only: S1–S3 and S5 sit behind one debug build flag; a release export has none and accepts no `--debug-seams`: a game protocol with the flag off exits nonzero and writes no run folder; only the CI `self-test` runs without it |
| H3 | Telemetry sink: the S4 log is a plain Godot log file, headless and graphical ([ADR-0001](../adr/decisions/0001-godot-gdscript.md)); the harness supplies the session/build id, and the run folder holds it ([`evidence.md`](../playtest/evidence.md)). Layout is `<run-dir>/integration/results.md`, `samples/` (frame and hitch NDJSON), `logs/` (S4 log and S5 dumps), and `results/` (raw protocol JSON); the harness never writes `manifest.md` |
| H4 | No seed needed: identical setups play identically ([`game-state.md`](../design/game-state.md) Q1). `SIT.1`–`SIT.2` stay unbuilt until a protocol cites one; `SIT.3` is realized by S5 because [`PTD-crosses-and-fills`](../playtest/design/crosses-and-fills.md) cites it |
| H5 | An `I6`–`I8` lane time is an observation only when a leg's `until` was met and its action did not fail; a failed leg still fails its row, reported not completed with no millisecond figure |

## Diagram

None.
