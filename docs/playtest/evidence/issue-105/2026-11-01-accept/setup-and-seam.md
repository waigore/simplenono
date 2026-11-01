# Setup and seam — issue #105

What the run drove, and what it could not.

## Build

- `main@dfd3ca4` in the dispatched worktree, fast-forwarded from `origin/main` with a clean tree.
- `git diff 4c8d1e5 HEAD -- game/` is empty: the game code under acceptance is exactly PR #124's merged content.
- Godot `4.7.2.stable.official.ed1daf0bf`, the version `Unit tests` CI uses.
- `godot --headless --path game --import` → DONE, exit 0 ([`logs/godot-import.log`](logs/godot-import.log)).

## Seam

`CMP-pack` is L3 records code with no UI caller yet ([`CTR-pack`](../../../../../specs/technical/contracts/pack.md)
consumers are `CMP-shell` and `CMP-attempt`, which land in #108–#111). Seam S6
([`verification.md`](../../../../../specs/technical/verification.md)) is the headless GUT run, so the
judged surface is:

1. The GUT suite — [`logs/gut-accept.log`](logs/gut-accept.log):
   `Scripts 4 / Tests 52 / Passing 52 / Asserts 27842 / exit 0`.
2. A temporary `SceneTree` probe that calls `Pack.load_pack()` (O8) and `Pack.definition(id)` (O3)
   and compares every served definition to the raw `res://data/pack.json` entry —
   [`logs/seam-probe.log`](logs/seam-probe.log). The probe was removed afterwards; the worktree
   carries only this evidence folder.
3. An independent Python audit that recomputes F3/F4 runs from F5 without using the repo validator —
   [`logs/independent-pack-audit.log`](logs/independent-pack-audit.log).
4. The pack generator's `--check` and its own tests —
   [`logs/pack-generator-check.log`](logs/pack-generator-check.log).

## Tool note

Godot's JSON parser returns every number as a float, so `served.row_clues == entry["row-clues"]`
is false even when the values agree (`[1, 2] != [1.0, 2.0]`). The probe therefore compares clue
integers numerically. The repo validator already normalizes with `int()`; this is a probe detail,
not a deliverable defect.

## Missing surface

`game/main.tscn` is a single bare `Node`; `game/presentation/` is empty. There is no board, no
`DBG.1`–`DBG.4` debug UI, and no `TEL.1`–`TEL.5` telemetry, so no protocol step that needs a
running puzzle screen can be driven or observed.
