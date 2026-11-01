class_name ClueLine
extends RefCounted
## One clue line of the open puzzle (specs/design/entities/clue.md P1-P3).
##
## A line is one orientation, one index, and the run lengths the pack ships
## ([SCH-puzzle-def] F3/F4). The runs are pack data, kept verbatim: nothing here
## reads the solution fills, and nothing here decides whether the line is
## satisfied or in error (that is [CMP-rules] R2/R3, specs/technical/components/rules.md).

enum Orientation { ROW, COLUMN }

## Which row `i` or column `j` this line is (specs/design/entities/clue.md P1).
var orientation: ClueLine.Orientation

## 0 … size-1 (specs/design/entities/clue.md P2).
var index: int

## Ordered positive integers; an empty list is the all-empty line
## (specs/design/entities/clue.md P3). Copied at construction.
var run_lengths: Array[int] = []


func _init(line_orientation: ClueLine.Orientation, line_index: int, runs: Array[int]) -> void:
	assert(line_index >= 0, "Clue line index must not be negative: %s" % line_index)
	orientation = line_orientation
	index = line_index
	run_lengths = runs.duplicate()


## True for an all-empty line (specs/design/entities/clue.md P3).
func is_empty() -> bool:
	return run_lengths.is_empty()


func equals(other: ClueLine) -> bool:
	return (
		other != null
		and other.orientation == orientation
		and other.index == index
		and other.run_lengths == run_lengths
	)


func _to_string() -> String:
	var name := "row" if orientation == Orientation.ROW else "column"
	return "%s %d %s" % [name, index, run_lengths]
