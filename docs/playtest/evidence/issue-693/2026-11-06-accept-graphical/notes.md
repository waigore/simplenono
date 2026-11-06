# Playtest notes — issue #693 (graphical acceptance)

## Run

- **Command** (repo root, fresh `user://`):
  `xvfb-run -a -s "-screen 0 1080x1200x24" godot --path game --rendering-driver opengl3 -s res://probe_accept_693.gd -- --debug-seams --session-id=issue-693-accept --build-id=main@23e1856 --story-ids=US1.14 --shot-dir=<run>/screenshots --run-folder=<run>`
  after copying [`probe_accept_693.gd`](probe_accept_693.gd) into `game/` (removed after).
- **Fresh `user://`**: `~/.local/share/simplenono/{gallery-prefs,progress}.cfg` removed
  before launch (`config/use_custom_user_dir`).
- Exit 0, `capture: RESULT pass (7 shots, 0 checks failed)`.

## Fixtures

- `pack-000` is seeded ever-completed through `CTR-pack` O6 (`record_solve`) so R2 has a
  tile the filter hides; `pack-001` is started through the player's own `Attempt` with
  one marked cell (in progress), which keeps it visible and gives C2's `EX.confirm` a
  target (`Present reset confirm` refuses a fresh tile).
- R1 reads `Completed 1 / 200` with the filter on: the count keeps the whole-pack
  denominator, as `gallery/filter.md` requires.

## Frames

- Narrow 900×1200 (two columns, below the wide breakpoint) and wide 1080×900 (four
  columns), the same frames the #692 gallery acceptance used.
