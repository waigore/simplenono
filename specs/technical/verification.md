# Verification

Authoring rules: [`.agents/specs/rules/technical/verification.md`](../../.agents/specs/rules/technical/verification.md).

- **Serves**: The playtest Debug UI and telemetry Must rows ([`DBG.1`](../playtest/tools.md)–`DBG.4`, `TEL.1`–`TEL.5`)
- **Informed by**: [`CMP-shell`](components/shell.md), [`CMP-attempt`](components/attempt.md), [`CTR-attempt`](contracts/attempt.md), [`CTR-pack`](contracts/pack.md), [`persistence.md`](persistence.md), [`quality.md`](../definition/quality.md)
- **ADRs**: [ADR-0001](../adr/decisions/0001-godot-gdscript.md)

## Seams

| ID | Seam | Purpose | How to drive |
|----|------|---------|--------------|
| S1 | Session control | Realizes `DBG.1`, `DBG.3`: halt or continue the session, and open a chosen puzzle id in place | Debug command in a debug build; calls [`CTR-attempt`](contracts/attempt.md) O4, O5, and O1 |
| S2 | State inspect | Realizes `DBG.2`: read the attempt and a progress record, changing nothing | Debug command returns [`SCH-attempt`](schemata/attempt.md), [`SCH-mark-grid`](schemata/mark-grid.md), and [`SCH-progress`](schemata/progress.md) |
| S3 | Story-ID overlay | Realizes `DBG.4`: show active story IDs | Debug toggle on [`CMP-shell`](components/shell.md), fed by the running protocol |
| S4 | Telemetry events | Realizes `TEL.1`–`TEL.5`: open, ready, mark, solved, pause, resume, leave, commit, and reset each emit one event with name, timestamp, session / build id, story id, and outcome | Components emit during play; [`CMP-shell`](components/shell.md) logs one line per event under the debug flag |

## Invariants to assert

[`verification/invariants.md`](verification/invariants.md) (I1–I11), including each Applies deterministic quality axis.

## Harness expectations

| ID | Expectation |
|----|-------------|
| H1 | Seams precede playtesting: the first build running a playtest protocol already contains S1–S4. A build without them is not a valid playtest target, and no gate run at `status:pending-acceptance` starts on one |
| H2 | Debug builds only: S1–S3 sit behind one debug build flag; a release export has none |
| H3 | Telemetry sink: the S4 log is a plain Godot log file, headless and graphical ([ADR-0001](../adr/decisions/0001-godot-gdscript.md)); the harness supplies the session / build id, and the run folder holds the file ([`evidence.md`](../playtest/evidence.md)) |
| H4 | No seed needed: identical setups play identically ([`game-state.md`](../design/game-state.md) Q1). `SIT.1`–`SIT.3` stay unbuilt until a protocol cites one |

## Diagram

None — the seams are drive lists, not a graph.
