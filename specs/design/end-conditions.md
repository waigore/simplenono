# Win and Loss Conditions

Authoring rules: [`.agents/specs/rules/design/end-conditions.md`](../../.agents/specs/rules/design/end-conditions.md).

Win and other endings match player objectives in [`../definition/definition.md`](../definition/definition.md): fill-set match wins; no lose state. State fields: [`game-state.md`](game-state.md). Solve steps: [`loops/solve.md`](loops/solve.md). Progress: [`progression.md`](progression.md).

## Units of play

| Unit | Win | Loss | Other endings |
|------|-----|------|---------------|
| Puzzle attempt | Player fills match the solution fill set | None | Leave to gallery |
| Pack | All 200 puzzles ever completed | None | None |

## Conditions

| ID | Unit | Type | Condition | Checked when | Outcome |
|----|------|------|-----------|--------------|---------|
| W1 | Puzzle | win | [`GS.is-solved`](game-state.md) (fills only; crosses ignored) | After a mark change while marks are allowed | Timer stops; [`GS.ever-completed`](game-state.md) → true; attempt → not started; marks and elapsed clear; [personal best](glossary.md) updates if shorter; gallery [thumbnail](glossary.md) may show; same on replay |
| O1 | Puzzle | other | Player leaves to gallery | Leave ([`L-solve.K6`](loops/solve.md)) | Marks, in-progress attempt, and elapsed commit when applicable; return to gallery |
| O2 | Puzzle | other | Player [resets](glossary.md) that puzzle in the gallery | Gallery reset | Puzzle is new: marks, elapsed, personal best, and ever-completed cleared; attempt → not started |
| W2 | Pack | win | Every puzzle is ever-completed ([`GS.completion-rate`](game-state.md) = 1) | After a puzzle becomes ever-completed | Pack finished ([`PRG.Z1`](progression.md)); replay for a better personal best still allowed |

No loss conditions.

## Precedence

- **P1**: For one puzzle attempt, W1 and O1 do not fire from the same action. O2 is only from the gallery. W2 is evaluated after W1 when that solve makes the last not-yet-ever-completed puzzle ever-completed; it does not replace W1.

## Rewards and penalties

- **W1**: Ever-completed (and gallery thumbnail) and optional better personal best ([`PRG.A1`](progression.md), [`PRG.A2`](progression.md)).
- **W2**: Pack finished only — no extra economy.
- **O1** / **O2**: No reward. O2 wipes that puzzle’s progress as new.

## Experience intent

Win is a quiet triumph: calm-yet-triumphant sting and, on the result screen, fills fading into the stored pixel picture, then into the stored generated picture ([`experience.md`](experience.md), [`PER.R5`](../view/perception.md)), including on replay; then return to gallery. Leave is calm pause. Gallery reset is a deliberate start-over as new. There is no loss to make fair.
