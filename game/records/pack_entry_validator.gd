class_name PackEntryValidator
extends RefCounted
## Validates one pack entry against [SCH-puzzle-def] F1–F7 and I1–I3.
##
## Used by [b]CMP-pack[/b] at pack load ([b]CTR-pack[/b] O8). Uniqueness (I4–I5) needs
## the accepted pack, so the loader checks it. Returns the accepted definition, or
## null when the entry must be rejected, together with a reason for the log.

## The field names of F1–F7 as they appear in the pack.
const FIELDS: Array[String] = [
	"id", "size", "row-clues", "col-clues", "solution-fills", "picture-id", "pixel-picture-id",
]
const SIZES: Array[int] = [10, 15, 20]


## The definition for [param entry], or null with [param reason] set to the first
## field or invariant that fails. [param reason] stays empty on success.
static func definition_for(entry: Variant, reason: Array[String] = []) -> PuzzleDefinition:
	reason.clear()
	if typeof(entry) != TYPE_DICTIONARY:
		reason.append("entry is not an object")
		return null
	var fields: Dictionary = entry
	for field in FIELDS:
		if not fields.has(field):
			reason.append("missing %s" % field)
			return null
	if typeof(fields["id"]) != TYPE_STRING or fields["id"].is_empty():
		reason.append("id is not a non-empty string")
		return null
	if not _is_whole_number(fields["size"]):
		reason.append("size is not 10, 15, or 20")
		return null
	var size := int(fields["size"])
	if size not in SIZES:
		reason.append("size is not 10, 15, or 20")
		return null
	for field in ["picture-id", "pixel-picture-id"]:
		if typeof(fields[field]) != TYPE_STRING or fields[field].is_empty():
			reason.append("%s is not a non-empty string" % field)
			return null
	var row_clues := _clue_lists(fields["row-clues"], size)
	var col_clues := _clue_lists(fields["col-clues"], size)
	if row_clues.is_empty():
		reason.append("row-clues is not %s lists of positive integers" % size)
		return null
	if col_clues.is_empty():
		reason.append("col-clues is not %s lists of positive integers" % size)
		return null
	var fills: Variant = _fills(fields["solution-fills"], size)
	if fills == null:
		reason.append("solution-fills is not a set of positions inside the grid")
		return null
	var filled: Array[Vector2i] = fills
	if _runs(filled, size, true) != row_clues:
		reason.append("row-clues are not the runs of solution-fills")
		return null
	if _runs(filled, size, false) != col_clues:
		reason.append("col-clues are not the runs of solution-fills")
		return null
	return PuzzleDefinition.new(
		fields["id"], size, row_clues, col_clues, filled, fields["picture-id"], fields["pixel-picture-id"],
	)


## True when [param entry] repeats a field of an earlier accepted entry ([SCH-puzzle-def]
## I4, I5). The loader passes the ids of the entries it has already accepted.
static func repeats_accepted(
	entry: Dictionary, accepted_ids: Dictionary, accepted_pictures: Dictionary,
) -> String:
	var id: String = entry.get("id", "")
	var picture: String = entry.get("picture-id", "")
	var pixel: String = entry.get("pixel-picture-id", "")
	if picture == pixel:
		return "picture-id and pixel-picture-id are the same id"
	if accepted_ids.has(id):
		return "id %s already accepted" % id
	if accepted_pictures.has(picture):
		return "picture-id %s already accepted" % picture
	if accepted_pictures.has(pixel):
		return "pixel-picture-id %s already accepted" % pixel
	return ""


## The run lengths of every line of [param fills], as size lists (F3 when [param by_row],
## F4 otherwise). An empty line gives [].
static func _runs(fills: Array[Vector2i], size: int, by_row: bool) -> Array:
	var runs: Array = []
	for line in size:
		var run_lengths: Array = []
		var length := 0
		for step in size:
			var position := Vector2i(line, step) if by_row else Vector2i(step, line)
			if fills.has(position):
				length += 1
			elif length > 0:
				run_lengths.append(length)
				length = 0
		if length > 0:
			run_lengths.append(length)
		runs.append(run_lengths)
	return runs


## [param value] as size lists of positive integers, or [] when it is not that shape.
## JSON numbers arrive as floats, so a whole number counts as an integer.
static func _clue_lists(value: Variant, size: int) -> Array:
	if typeof(value) != TYPE_ARRAY:
		return []
	var lists: Array = value
	if lists.size() != size:
		return []
	var clue_lists: Array = []
	for list: Variant in lists:
		if typeof(list) != TYPE_ARRAY:
			return []
		var clue_list: Array = []
		for run: Variant in list:
			if not _is_whole_number(run) or int(run) <= 0:
				return []
			clue_list.append(int(run))
		clue_lists.append(clue_list)
	return clue_lists


## [param value] as de-duplicated in-grid positions, or null when it is not that shape.
static func _fills(value: Variant, size: int) -> Variant:
	if typeof(value) != TYPE_ARRAY:
		return null
	var cells: Array = value
	var fills: Array[Vector2i] = []
	for cell: Variant in cells:
		if typeof(cell) != TYPE_ARRAY or cell.size() != 2:
			return null
		var row: Variant = cell[0]
		var column: Variant = cell[1]
		if not _is_whole_number(row) or not _is_whole_number(column):
			return null
		var position := Vector2i(int(row), int(column))
		if not _is_inside(position, size):
			return null
		if not fills.has(position):
			fills.append(position)
	fills.sort()
	return fills


static func _is_inside(position: Vector2i, size: int) -> bool:
	return position.x >= 0 and position.x < size and position.y >= 0 and position.y < size


## True for an int or a float with no fractional part (JSON numbers parse as floats).
static func _is_whole_number(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return true
	if typeof(value) == TYPE_FLOAT:
		return float(value) == floorf(float(value))
	return false
