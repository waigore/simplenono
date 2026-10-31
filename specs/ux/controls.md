# Controls

Authoring rules: [`.agents/specs/rules/ux/controls.md`](../../.agents/specs/rules/ux/controls.md).

## UI actions

| ID | Action | Meaning |
|----|--------|---------|
| `IN.confirm` | Confirm | Accept the focused choice. |
| `IN.cancel` | Cancel | Dismiss without accepting. |
| `IN.back` | Back | Return to the previous screen. |
| `IN.pause` | Pause | From an open puzzle, open settings; [`GS.paused`](../design/game-state.md) until Back resumes the puzzle. |
| `IN.point` | Point | Move keyboard focus among that screen's controls. |
| `IN.activate` | Activate | Invoke the focused or pointed control. |
| `IN.mark-complement` | Mark complement | On a puzzle cell, apply the fill↔cross complement of the selected tool (see Mark tools). |
| `IN.drag-paint` | Drag-paint | Apply the selected tool's mark along cells under a held drag (no per-cell toggle). |

## Mark tools (puzzle)

Selected tool is Fill, Cross, or Clear ([`UI-puzzle`](screens/puzzle.md) C3–C5).

- **Tap / click (`IN.activate` on a cell)**: Apply the selected tool. Fill or Cross on a cell that already has that mark clears it. Clear sets clear (no-op if already clear).
- **Drag-paint (`IN.drag-paint`)**: Hold and paint a run; each cell under the drag receives the selected tool's mark (fill, cross, or clear) — no per-cell toggle.
- **Secondary (`IN.mark-complement`)**: Fill → Cross; Cross → Fill; Clear → Cross. Same toggle-if-same rule as a primary Fill/Cross tap.

## Bindings

Full table: [`controls/bindings.md`](controls/bindings.md).

## Focus

- **F1**: On each screen, keyboard focus follows that screen's controls table top to bottom. Pointer activation hits the control under the pointer. An unavailable control shows that it is unavailable and does not activate.
