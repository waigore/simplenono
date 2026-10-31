# Progress Management

Authoring rules: [`.agents/specs/rules/design/progression.md`](../../.agents/specs/rules/design/progression.md).

Serves free-order pack play, gallery-style completion, and personal-best scoring from the vision and definition. The [gallery](glossary.md) is the pack’s free-order selection: every puzzle is always listed and selectable, each with a status and, when one exists, a personal best.

## Progression axes

| ID | Axis | Kind | Advanced by | Cap |
|----|------|------|-------------|-----|
| A1 | Puzzle completion | collection | Solving a puzzle (player fills match the solution fill set) | 200 (60×10×10, 140×15×15); all available from the start |
| A2 | Personal-best times | collection | A successful solve; a shorter time replaces the stored best | One best per puzzle |

## Unlocks

None — no content gates. Every puzzle is selectable immediately.

## Persistence

| ID | What | Persists across | Lost or reset when |
|----|------|-----------------|--------------------|
| P1 | Per-puzzle status: not started, in progress, or completed | Sessions | Player [reset](glossary.md) returns status to not started; otherwise never in normal play |
| P2 | Per-puzzle personal best | Sessions | Replaced only by a shorter successful solve time; kept across reset |
| P3 | In-progress cell marks (clear / fill / cross) | Sessions while status is in progress | Cleared on reset or when the puzzle becomes completed |
| P4 | In-progress solve elapsed | Sessions while status is in progress | Cleared on reset or when the puzzle becomes completed; resumes on reopen |

## Committing progress

- **M1**: Status, marks, elapsed, and personal best commit when they change (marks and elapsed while solving; status and best on a successful solve). After an interruption, play resumes in the gallery. Opening an in-progress puzzle restores its marks and elapsed time.

## Failure consequences

- **F1**: None — there is no fail state; wrong marks are corrected, not punished.

## Completion

- **Z1**: The pack is finished when all 200 puzzles have status completed. [Completion rate](glossary.md) (completed count ÷ 200) is ongoing progression feedback visible from the gallery.
- **Z2**: After pack finish, and whenever a puzzle is already completed, the player may replay it to improve its personal best.
- **Z3**: Same as finishing (Z1).

## Attempt timing

A short [get-set-ready](glossary.md) beat prepares the player before marks are allowed. The solve timer starts when that puzzle attempt loads (board ready after get-set-ready), or resumes persisted elapsed when reopening an in-progress puzzle. The timer stops when the player's fills match the solution fill set.

## Experience intent

Quiet gallery progress: statuses fill in, completion rate makes pack progress clear, and chasing better times stays optional.
