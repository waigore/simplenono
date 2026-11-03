# Control bindings

Authoring rules: [`.agents/specs/rules/ux/controls.md`](../../../.agents/specs/rules/ux/controls.md).

Parent: [`../controls.md`](../controls.md). Platforms from [`definition.md`](../../definition/definition.md).

| ID | Platform | Input | Action |
|----|----------|-------|--------|
| B1 | Windows | Primary click | `IN.activate` |
| B2 | Windows | Secondary click (cell) | `IN.mark-complement` |
| B3 | Windows | Drag on cells | `IN.drag-paint` |
| B4 | Windows | Enter / Space | `IN.confirm` / `IN.activate` |
| B5 | Windows | Escape | `IN.cancel` / `IN.back` |
| B6 | Windows | Arrows | `IN.point` |
| B7 | Windows | F | `IN.activate` (Fill tool) |
| B8 | Windows | X | `IN.activate` (Cross tool) |
| B9 | Windows | C | `IN.activate` (Clear tool) |
| B10 | Windows | P | `IN.pause` |
| B11 | macOS | Primary click | `IN.activate` |
| B12 | macOS | Secondary click (cell) | `IN.mark-complement` |
| B13 | macOS | Drag on cells | `IN.drag-paint` |
| B14 | macOS | Enter / Space | `IN.confirm` / `IN.activate` |
| B15 | macOS | Escape | `IN.cancel` / `IN.back` |
| B16 | macOS | Arrows | `IN.point` |
| B17 | macOS | F | `IN.activate` (Fill tool) |
| B18 | macOS | X | `IN.activate` (Cross tool) |
| B19 | macOS | C | `IN.activate` (Clear tool) |
| B20 | macOS | P | `IN.pause` |
| B21 | Linux | Primary click | `IN.activate` |
| B22 | Linux | Secondary click (cell) | `IN.mark-complement` |
| B23 | Linux | Drag on cells | `IN.drag-paint` |
| B24 | Linux | Enter / Space | `IN.confirm` / `IN.activate` |
| B25 | Linux | Escape | `IN.cancel` / `IN.back` |
| B26 | Linux | Arrows | `IN.point` |
| B27 | Linux | F | `IN.activate` (Fill tool) |
| B28 | Linux | X | `IN.activate` (Cross tool) |
| B29 | Linux | C | `IN.activate` (Clear tool) |
| B30 | Linux | P | `IN.pause` |
| B31 | iOS | Tap | `IN.activate` |
| B32 | iOS | Drag on cells | `IN.drag-paint` |
| B33 | iOS | Puzzle Settings | `IN.pause` |
| B34 | Android | Tap | `IN.activate` |
| B35 | Android | Drag on cells | `IN.drag-paint` |
| B36 | Android | Puzzle Settings | `IN.pause` |
| B37 | Android | Phone/system Back | `IN.back` |

F / X / C activate [`UI-puzzle`](../screens/puzzle.md) C3–C5. Escape is `IN.cancel` on `EX.confirm`, else `IN.back`; Enter/Space is `IN.confirm`, else `IN.activate`. Gallery Settings uses `IN.activate` ([`UI-gallery.C3`](../screens/gallery.md)), not `IN.pause`.

B37 takes Escape's `IN.back` route, not a second seam: `UI-puzzle.C1` leaves to the gallery, `UI-settings.C3` goes back or resumes, and `UI-result.C1` goes to the gallery when available and does nothing while not. On `UI-gallery` the notification passes to the platform unchanged. While `EX.confirm` shows it is consumed with no effect; it never raises `IN.cancel` or places a mark.
