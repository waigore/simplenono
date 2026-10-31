# Control bindings

Authoring rules: [`.agents/specs/rules/ux/controls.md`](../../../.agents/specs/rules/ux/controls.md).

Parent: [`../controls.md`](../controls.md). Platforms from [`definition.md`](../../definition/definition.md).

| ID | Platform | Input | Action |
|----|----------|-------|--------|
| B1 | Windows | Pointer primary click | `IN.activate` |
| B2 | Windows | Pointer secondary click (puzzle cell) | `IN.mark-complement` |
| B3 | Windows | Pointer drag on cells | `IN.drag-paint` |
| B4 | Windows | Keyboard Enter / Space | `IN.confirm` / `IN.activate` |
| B5 | Windows | Keyboard Escape | `IN.cancel` / `IN.back` |
| B6 | Windows | Keyboard arrows | `IN.point` |
| B7 | Windows | Keyboard F | `IN.activate` (Fill tool) |
| B8 | Windows | Keyboard X | `IN.activate` (Cross tool) |
| B9 | Windows | Keyboard C | `IN.activate` (Clear tool) |
| B10 | Windows | Keyboard P | `IN.pause` |
| B11 | macOS | Pointer primary click | `IN.activate` |
| B12 | macOS | Pointer secondary click (puzzle cell) | `IN.mark-complement` |
| B13 | macOS | Pointer drag on cells | `IN.drag-paint` |
| B14 | macOS | Keyboard Enter / Space | `IN.confirm` / `IN.activate` |
| B15 | macOS | Keyboard Escape | `IN.cancel` / `IN.back` |
| B16 | macOS | Keyboard arrows | `IN.point` |
| B17 | macOS | Keyboard F | `IN.activate` (Fill tool) |
| B18 | macOS | Keyboard X | `IN.activate` (Cross tool) |
| B19 | macOS | Keyboard C | `IN.activate` (Clear tool) |
| B20 | macOS | Keyboard P | `IN.pause` |
| B21 | Linux | Pointer primary click | `IN.activate` |
| B22 | Linux | Pointer secondary click (puzzle cell) | `IN.mark-complement` |
| B23 | Linux | Pointer drag on cells | `IN.drag-paint` |
| B24 | Linux | Keyboard Enter / Space | `IN.confirm` / `IN.activate` |
| B25 | Linux | Keyboard Escape | `IN.cancel` / `IN.back` |
| B26 | Linux | Keyboard arrows | `IN.point` |
| B27 | Linux | Keyboard F | `IN.activate` (Fill tool) |
| B28 | Linux | Keyboard X | `IN.activate` (Cross tool) |
| B29 | Linux | Keyboard C | `IN.activate` (Clear tool) |
| B30 | Linux | Keyboard P | `IN.pause` |
| B31 | iOS | Touch tap | `IN.activate` |
| B32 | iOS | Touch drag on cells | `IN.drag-paint` |
| B33 | iOS | Puzzle Settings control | `IN.pause` |
| B34 | Android | Touch tap | `IN.activate` |
| B35 | Android | Touch drag on cells | `IN.drag-paint` |
| B36 | Android | Puzzle Settings control | `IN.pause` |

F / X / C activate [`UI-puzzle`](../screens/puzzle.md) C3–C5. Escape is `IN.cancel` on `EX.confirm`, else `IN.back`. Enter/Space is `IN.confirm` on `EX.confirm`, else `IN.activate`. Gallery Settings uses `IN.activate` ([`UI-gallery.C3`](../screens/gallery.md)), not `IN.pause`.
