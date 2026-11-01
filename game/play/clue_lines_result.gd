class_name ClueLinesResult
extends RefCounted
## Outcome of [method ClueLines.from_definition].
##
## Either the 2 × size lines of the open puzzle, or a mapping error naming what
## the pack entry got wrong ([SCH-puzzle-def] I1). Never both: lines exist only
## when [member error] is empty.

## Why the definition could not map to lines; empty on success.
var error: String = ""

## Exactly `size` row lines then `size` column lines, in index order. Empty on error.
var lines: Array[ClueLine] = []

var _size: int = 0


func _init(definition_size: int) -> void:
	_size = definition_size


func ok() -> bool:
	return error.is_empty()


## The row line for this index (specs/design/entities/clue.md P1/P2).
func row(index: int) -> ClueLine:
	return _line(ClueLine.Orientation.ROW, index)


## The column line for this index (specs/design/entities/clue.md P1/P2).
func column(index: int) -> ClueLine:
	return _line(ClueLine.Orientation.COLUMN, index)


## The lines of one orientation in index order.
func lines_for(orientation: ClueLine.Orientation) -> Array[ClueLine]:
	var selection: Array[ClueLine] = []
	for line in lines:
		if line.orientation == orientation:
			selection.append(line)
	return selection


func _line(orientation: ClueLine.Orientation, index: int) -> ClueLine:
	assert(ok(), "No clue lines: %s" % error)
	assert(index >= 0 and index < _size, "Line index outside 0…size-1: %s" % index)
	var offset := 0 if orientation == ClueLine.Orientation.ROW else _size
	return lines[offset + index]
