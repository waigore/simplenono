# Failure — `PTU-gallery-reset` cannot be completed on this build

The protocol's `S2` (Cancel on `EX.confirm`) and `S3` (Confirm) need a confirm surface the
build does not ship. `F2`'s second clause, "confirm never appears", is literally true — but it
is true **by design boundary**, not because a #94 deliverable is broken:

- `specs/ux/stories/exceptions.md` `EX.confirm` `US1.1`–`US1.3` and `SEQ reset` `S2`/`S3`
  (Confirm → `O7`) are owned by **epic #96**, which is still open in
  `status:pending-clarification`.
- #94's own scope stops at `S1` (show when allowed), `B1`, `B2` (cancel leg), `S5`, `S6`, and
  `UI-gallery.C2` allowedness — the epic body's single-owner table says this explicitly.
- `game/presentation/shell.gd` `_on_gallery_reset_requested` documents the same boundary: the
  reset intent ends there, and `S2`–`S4` "stay in #96's confirm flow".

So the protocol cannot pass until #96 lands. Under
[`procedures.md`](../../../../../specs/playtest/procedures.md) that is **Waiting**, and
[citing `accept-project-issue`'s outcome list] it is neither **Fail** (no game or interface
reason in a delivered element) nor **Clarify** (no product-owner question is open — the
ownership boundary is already decided and written down).

## What this run did prove on the reset journey

- `S1`: the C2 trigger fires for an ever-completed puzzle and the intent reaches `CMP-shell`;
  the gallery stays Default and **nothing is cleared** without a Confirm.
- `B1`: C2 refused on a not-started puzzle reaches no one and changes nothing.
- `S5` / `N2`: after `CTR-pack.O7` — the operation #94 owns, including its `G3` file
  replacement — the tile reads `Not started`, loses its Best, withdraws Reset, and the
  completion count drops; leaving a puzzle re-reads `O1`/`O2` the same way. The screenshots
  `02-g3-gallery-after-o7-refresh.png` and `03-g4-gallery-after-leave-reread.png` show it.

## Not a defect

No Defect issue is filed. The miss is a missing surface owned by another epic (#96), not wrong
behavior in #94's game or interface. Filing one would duplicate #96's work.
