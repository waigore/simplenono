# Loop: Solve

Authoring rules: [`.agents/specs/rules/design/loops.md`](../../../.agents/specs/rules/design/loops.md).

- **Level**: core
- **Timescale**: Seconds to minutes (one puzzle attempt)
- **Serves**: Calm tactile grid and Snappy solve; local pack play and free-order selection
- **Parent / child loops**: Parent — open a [puzzle](../entities/puzzle.md) from the [gallery](../glossary.md). Child — None

## Steps

| ID | Player does | Game responds | Player gains or learns |
|----|-------------|---------------|------------------------|
| K1 | Enter [get-set-ready](../glossary.md) | Board loads; marks blocked briefly; when ready, empty-[clue](../entities/clue.md) lines auto-cross still-clear cells (counts as crosses → [in progress](../glossary.md) if any); solve timer starts (or resumes persisted elapsed) | Ready to solve |
| K2 | Fill a cell, place a [cross](../glossary.md), or clear a mark | Mark updates; first fill or cross (including K1 auto-cross) sets [attempt status](../glossary.md) to [in progress](../glossary.md) without clearing [ever completed](../glossary.md); [line error](../glossary.md) may update; [clue](../entities/clue.md) line may dim when satisfied | Deduction progress from clues |
| K3 | Keep marking | No per-cell correctness. [Solve check](../glossary.md) compares **fills only** to the solution fill set | Whether the picture fills are complete |
| K4 | Reach a fill set that matches the solution | Timer stops; ever-completed → true; attempt → not started; marks and elapsed clear; [personal best](../glossary.md) updates if shorter ([`END.W1`](../end-conditions.md)); same on replay | The clean-solve click |
| K5 | Pause (settings from puzzle, or desktop P) | [`GS.paused`](../game-state.md) → true; elapsed stops; marks blocked; settings opens | Can adjust prefs without quitting the attempt |
| K6 | Leave mid-puzzle | Marks, in-progress attempt, and elapsed commit; clear pause; return to the gallery ([`END.O1`](../end-conditions.md)) | Can resume later with the same elapsed |

## Motivation

Quiet focused deduction: finish the picture, or optionally chase a better personal best on replay while remaining ever-completed. Crosses are optional memory aids. [Reset](../glossary.md) is a gallery action, not an on-board step.

## Inputs and outputs

- **In**: Selected puzzle; restored marks and elapsed when attempt is in progress; row and column clues.
- **Out**: Updated marks, attempt status, ever-completed on solve, elapsed, and line errors; on K4, personal-best update when shorter.

## Variation

Which puzzle and size (10×10, 15×15, or 20×20) the player chose. No randomness during a solve.

## Exits

- **E1**: Solved — fills match the solution (K4); ever-completed; attempt cleared ([`END.W1`](../end-conditions.md)).
- **E2**: Leave to gallery (K6); in-progress marks and elapsed persist when applicable ([`END.O1`](../end-conditions.md)).

Pause (K5) is not an exit — settings covers the puzzle until Back. No loss exit. Gallery [reset](../glossary.md) is [`END.O2`](../end-conditions.md), outside this loop.

## Experience intent

Snappy mark response on a calm clinical board with soft SFX under calm BGM. Tension is deduction, not punishment. On solve: sting and the result-screen fades, fills then pixel picture then generated picture ([`experience.md`](../experience.md), [`PER.R5`](../../view/perception.md)), then gallery. Crosses aid memory; only fills win. Line errors flag impossible fills, not unfinished lines.
