class_name LineStatusCheck
extends RefCounted
## The [b]CTR-rules[/b] O2 return value: one [LineStatus] per row and per column.
##
## Ordered size rows then size columns, index order inside each half, the same
## order [ClueLinesResult] holds its lines in. Either the statuses or a mapping
## error naming what the definition got wrong ([SCH-puzzle-def] I1); never both.

## Why the definition could not map to lines; empty on success.
var error: String = ""

## Exactly size row statuses then size column statuses. Empty on error.
var statuses: Array[LineStatus] = []

var _size: int = 0


func _init(definition_size: int, mapping_error: String = "") -> void:
	_size = definition_size
	error = mapping_error


func ok() -> bool:
	return error.is_empty()


## The row status for this index ([SCH-line-status] F1/F2).
func row(index: int) -> LineStatus:
	return _line_status(ClueLine.Orientation.ROW, index)


## The column status for this index ([SCH-line-status] F1/F2).
func column(index: int) -> LineStatus:
	return _line_status(ClueLine.Orientation.COLUMN, index)


## The statuses of one orientation in index order.
func statuses_for(orientation: ClueLine.Orientation) -> Array[LineStatus]:
	var selection: Array[LineStatus] = []
	for status in statuses:
		if status.orientation == orientation:
			selection.append(status)
	return selection


func _line_status(orientation: ClueLine.Orientation, index: int) -> LineStatus:
	assert(ok(), "No line statuses: %s" % error)
	assert(index >= 0 and index < _size, "Line index outside 0…size-1: %s" % index)
	var offset := 0 if orientation == ClueLine.Orientation.ROW else _size
	return statuses[offset + index]
