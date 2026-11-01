class_name MarkCell
extends RefCounted
## One cell of the mark grid ([SCH-mark-grid]).
##
## Holds exactly one mark: clear, filled, or crossed ([SCH-mark-grid] I1,
## specs/design/entities/cell.md P2). The grid and its owner decide when a mark
## may change; this value only rejects a value that is not a mark.

var mark: CellMark.Mark:
	get:
		return _mark
	set(value):
		assert(CellMark.is_mark(value), "Unknown cell mark: %s" % value)
		if not CellMark.is_mark(value):
			return
		_mark = value

var _mark: CellMark.Mark = CellMark.Mark.CLEAR


## True when this cell counts toward solve and line-error fills (S2).
func is_filled() -> bool:
	return CellMark.counts_as_fill(_mark)
