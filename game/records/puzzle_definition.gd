class_name PuzzleDefinition
extends RefCounted
## One accepted pack entry ([SCH-puzzle-def]).
##
## Holds the seven fields F1–F7 exactly as the pack states them. Built only by
## [b]CMP-pack[/b] at load ([SCH-puzzle-def] L2), never changed during play (L4).
## Validation happens before a record exists; this type stores.

## F1 — stable id, unique in the accepted pack.
var id: String
## F2 — 10, 15, or 20.
var size: int
## F3 — one list of run lengths per row.
var row_clues: Array
## F4 — one list of run lengths per column.
var col_clues: Array
## F5 — the filled positions as row and column, row-major.
var solution_fills: Array[Vector2i]
## F6 — stored generated picture asset id.
var picture_id: String
## F7 — stored pixel picture asset id.
var pixel_picture_id: String


func _init(
	definition_id: String,
	grid_size: int,
	rows: Array,
	columns: Array,
	fills: Array[Vector2i],
	picture: String,
	pixel_picture: String,
) -> void:
	id = definition_id
	size = grid_size
	row_clues = rows
	col_clues = columns
	solution_fills = fills
	picture_id = picture
	pixel_picture_id = pixel_picture
