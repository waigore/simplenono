class_name CellMark
extends RefCounted
## A cell's single mark on the board ([SCH-mark-grid] F2).
##
## Clear, filled, or crossed. The place of the mark on the board is not stored
## here; the grid holds cells by row and column ([SCH-mark-grid] F1).
## See specs/design/entities/cell.md S1–S3.

enum Mark {
	CLEAR,
	FILL,
	CROSS,
}

const MARKS: Array[Mark] = [Mark.CLEAR, Mark.FILL, Mark.CROSS]

static var _names: Dictionary = {
	Mark.CLEAR: "clear",
	Mark.FILL: "fill",
	Mark.CROSS: "cross",
}


## True when [param value] is one of the three marks.
static func is_mark(value: Variant) -> bool:
	return typeof(value) == TYPE_INT and value in MARKS


## True when the mark counts toward solve and line-error fills ([SCH-mark-grid], S2).
static func counts_as_fill(mark: Mark) -> bool:
	return mark == Mark.FILL


static func mark_name(mark: Mark) -> String:
	assert(is_mark(mark), "Unknown cell mark: %s" % mark)
	return _names[mark]
