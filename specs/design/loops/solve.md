# Loop: Solve

Authoring rules: [`.agents/specs/rules/design/loops.md`](../../../.agents/specs/rules/design/loops.md).

- **Level**: core
- **Timescale**: Seconds to minutes (one puzzle attempt)
- **Serves**: Calm tactile grid and Snappy solve; local pack play and free-order selection
- **Parent / child loops**: Parent — open a puzzle from the [gallery](../glossary.md). Child — None

## Steps

| ID | Player does | Game responds | Player gains or learns |
|----|-------------|---------------|------------------------|
| K1 | Enter [get-set-ready](../glossary.md) | Board loads; marks blocked briefly; solve timer starts when the board is ready | Ready to solve |
| K2 | Fill a cell, mark a cell empty, or clear a mark | Mark updates; first change sets status to [in progress](../glossary.md) | Deduction progress from clues |
| K3 | Keep marking | No per-cell correctness. [Solve check](../glossary.md) runs only against the full grid | Whether the picture is complete |
| K4 | Reach a grid that matches the solution | Timer stops; status → [completed](../glossary.md); [personal best](../glossary.md) updates if this time is shorter | The clean-solve click |
| K5 | [Reset](../glossary.md) marks | All fills and empty-marks clear; status → [not started](../glossary.md); personal best unchanged; get-set-ready runs again and the timer starts fresh when the board is ready | A fresh attempt on the same board |
| K6 | Leave mid-puzzle | Marks and in-progress status commit; return to the gallery | Can resume later |

## Motivation

Quiet focused deduction: finish the picture, or optionally chase a better personal best on replay.

## Inputs and outputs

- **In**: Selected puzzle; restored marks when status is in progress; row and column clues.
- **Out**: Updated marks and status; elapsed solve time; on K4, personal-best update when shorter; on K5, cleared marks and not-started status.

## Variation

Which puzzle and size (10×10 or 15×15) the player chose. No randomness during a solve.

## Exits

- **E1**: Solved — full grid matches the solution (K4); status completed.
- **E2**: Leave to gallery (K6); in-progress marks persist when applicable.
- **E3**: Reset (K5); stays on the board for a fresh attempt. No loss exit.

## Experience intent

Snappy mark response on a calm clinical board. Tension is deduction, not punishment; no live “wrong cell” feedback.
