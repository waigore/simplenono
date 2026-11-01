class_name Shell
extends Control
## [b]CMP-shell[/b] stub: the app's first screen.
##
## Holds one stub data point, [constant STUB_PUZZLE_ID], and displays it. Nothing
## else is built yet: no attempt operation ([b]CTR-attempt[/b] C1), no pack call
## ([b]CTR-pack[/b] C2), no grid or clue drawing (R3), no navigation. The puzzle
## target scene and the shell → puzzle open leg are owned by #112; the real puzzle
## screen UI is #110. See specs/technical/components/shell.md.

## Stub puzzle id, chosen from the shipped pack ([b]CTR-pack[/b] pack layout).
## Shape is not fixed yet ([SCH-puzzle-def] F1); replace once #105 lands.
const STUB_PUZZLE_ID := "pack-000"

@onready var _puzzle_id_label: Label = %PuzzleIdLabel


func _ready() -> void:
	_puzzle_id_label.text = STUB_PUZZLE_ID
