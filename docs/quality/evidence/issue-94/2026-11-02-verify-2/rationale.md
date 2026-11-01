# Verification rationale — issue #94

Selection arguments are in [selection.md](selection.md); results are in
[manifest.md](manifest.md). This file records why the verdict is `Pass` and what remains
advisory.

## Why verification passes

The prior verification failed on two material items. Both are now fixed at `fe8c109`:

1. **`frame-time` is observed on navigation frames.** `navigate` opens a named `gallery`
   window and a named `reveal` window, and every sample carries its window. The run reads
   gallery p95 6.95 ms over 78 frames and reveal p95 6.94 ms over 173 frames — both under
   the 16.7 ms bar — and the prior `no-invariant` blocked row is gone.
2. **R2's tile picture matches both approved mockups.** The fixed 88 px band and stretched
   `draw_texture_rect` are replaced by a square, full-width picture region that fits a stored
   picture by its own proportions. Unit tests at 390 px and 1100 px and the harness layout
   expectations at the same edge sizes hold the shape and the 2/4 columns.

The serve side (`O1`, `O2`, `O7`, `CMP-pack` R4/`G3`), the gallery screen (`R1`–`R3`,
`C1`–`C3`, `S1`), and the shell reset legs (`S1`, `B1`, `S5`, `S6`) are unchanged and still
pass. `EX.confirm` and `SEQ reset` S2–S4 remain #96's by the epic's ownership table;
`US1.1` closes jointly with #96, as the story row says.

## What passed

Unit and harness evidence is in [checks.md](checks.md): GUT 220/220, the five headless
protocols, `review-code` Pass, spec lint clean apart from one pre-existing glossary warning,
and the UI gate compared against the approved `MC.gallery-mobile` / `MC.gallery-desktop` rows.

## Advisory (not fail causes)

- The I1 row still passes on the combined p95 while printing per-window figures; the
  suggestion in [review-code.md](review-code.md) would make each window authoritative. The
  current run passes every window, so the record is accurate.
- `navigate`'s comments and the integration README say the `gallery` window includes the
  return `refresh()`; those frames are actually tagged `reveal`. Documentation only.
- The `UI-gallery` story row still lacks the joint-#96 note that its `J-gallery-reset`
  sibling has; it does not change what is delivered.
- `relaunch.gd` still calls the shell home a "gallery stand-in".

## Verdict

`Pass` — see [manifest.md](manifest.md). No defect filed, no cascade, no `priority:*`
change.
