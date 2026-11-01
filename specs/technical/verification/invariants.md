# Verification invariants

Authoring rules: [`.agents/specs/rules/technical/verification.md`](../../../.agents/specs/rules/technical/verification.md).

Parent: [`../verification.md`](../verification.md).

| ID | Invariant | Level | When checked |
|----|-----------|-------|--------------|
| I1 | Frame time stays within the `quality.md` frame-time target during grid paint and navigation (`frame-time`) | integration | Every protocol run, from S4 samples |
| I2 | No hitch exceeds the `quality.md` hitch-bound target during grid paint (`hitch-bound`) | integration | Every protocol run |
| I3 | A mark or advance while blocked or paused changes nothing ([`CTR-attempt.G1`](../contracts/attempt.md)) | integration | After S1 drive in each marking protocol |
| I4 | Personal best never increases while set, and a committed record survives quit ([`CTR-pack.G1`](../contracts/pack.md), [`persistence.md`](../persistence.md) M1; `save-survives`, `failed-write`) | integration | Each solve, reset, and quit round-trip |
| I5 | [`SCH-progress`](../schemata/progress.md) I1–I6 hold after every committed step | smoke | Per run step |
| I6 | Cold launch to interactive gallery stays within `time-to-playable` | integration | App-start harness |
| I7 | Gallery↔puzzle, puzzle→result, and result→gallery stay within `transition-latency` | integration | Each navigation protocol |
| I8 | Open puzzle, settings toggle, and Back acknowledge within `response-delay` | integration | Each non-paint UI protocol |
| I9 | Open, solve, reset, and back complete without a crash (`crash-free`) | integration | Each of those flows |
| I10 | After kill mid-puzzle, next launch is gallery and reopen restores marks/elapsed (`resume-after-failure`) | integration | Kill-and-relaunch harness |
| I11 | Severity-tagged error/crash logs, frame/hitch samples, and story-ID telemetry events are present (`runtime-signals`) | smoke | Debug build with S4 |
| I12 | Each `res://data/pack.json` entry is accepted or rejected exactly as [`SCH-puzzle-def`](../schemata/puzzle-def.md) I1–I5 and [`CTR-pack`](../contracts/pack.md) O8 errors say, and a rejected entry leaves the rest of the pack loadable | unit | Every run of `game/test/` via seam S6 |

An axis holds only where `quality.md` sets Applies (`rubrics.md`: an N/A axis is not scored).
