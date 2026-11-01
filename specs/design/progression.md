# Progress Management

Authoring rules: [`.agents/specs/rules/design/progression.md`](../../.agents/specs/rules/design/progression.md).

Serves free-order pack play, gallery-style completion, and personal-best scoring from the vision and definition. The [gallery](glossary.md) lists every [puzzle](entities/puzzle.md) as selectable, with attempt status, [ever completed](glossary.md) when true, [personal best](glossary.md) when one exists, and a [thumbnail](glossary.md) only when ever completed.

## Progression axes

| ID | Axis | Kind | Advanced by | Cap |
|----|------|------|-------------|-----|
| A1 | Puzzle completion | collection | First successful solve sets ever-completed | 200 (10×10×10, 15×15×170, 20×20×20); all available from the start |
| A2 | Personal-best times | collection | A successful solve; a shorter time replaces the stored best | One best per puzzle |

## Unlocks

None — no content gates. Every puzzle is selectable immediately.

## Persistence

| ID | What | Persists across | Lost or reset when |
|----|------|-----------------|--------------------|
| P1 | Per-puzzle [ever completed](glossary.md) | Sessions | Gallery [reset](glossary.md) ([`END.O2`](end-conditions.md)) clears it |
| P2 | Per-puzzle [attempt status](glossary.md): not started or in progress | Sessions | Solve clears attempt to not started; gallery reset clears it |
| P3 | Per-puzzle personal best | Sessions | Replaced only by a shorter successful solve; cleared on gallery reset |
| P4 | In-progress cell marks (clear / fill / cross) | Sessions while attempt in progress | Cleared on successful solve or gallery reset |
| P5 | In-progress solve elapsed | Sessions while attempt in progress | Cleared on successful solve or gallery reset; resumes on reopen |

## Committing progress

- **M1**: Ever-completed, attempt status, marks, elapsed, and personal best commit when they change. After interruption, play resumes in the gallery. Opening an in-progress attempt restores marks and elapsed. Gallery reset treats that puzzle as new ([`END.O2`](end-conditions.md)).

## Failure consequences

- **F1**: None — there is no fail state; wrong marks are corrected, not punished.

## Completion

- **Z1**: The pack is finished when all 200 puzzles are ever-completed. [Completion rate](glossary.md) (ever-completed count ÷ 200) is ongoing gallery feedback.
- **Z2**: After pack finish, and whenever a puzzle is ever-completed, the player may replay it (attempt in progress while still ever-completed) to improve its personal best.
- **Z3**: Same as finishing (Z1).

## Attempt timing

A short [get-set-ready](glossary.md) beat ([`CFG.GET_SET_READY_MS`](configuration.md), default 500 ms) prepares the player before marks are allowed. The solve timer starts when that puzzle attempt loads (board ready after get-set-ready), or resumes persisted elapsed when reopening an in-progress attempt. The timer stops when the player's fills match the solution fill set.

## Experience intent

Quiet gallery progress: ever-completed and thumbnails fill in, completion rate makes pack progress clear, and chasing better times on replay stays optional.
