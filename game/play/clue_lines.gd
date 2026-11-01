class_name ClueLines
extends RefCounted
## Maps a [SCH-puzzle-def] entry onto the clue lines the puzzle shows
## (specs/design/entities/clue.md P1-P3, specs/design/stories/entities/clue.md PS1.1).
##
## Read-only over the definition: line `i` is F3 `i` and column `j` is F4 `j`,
## with the run lengths kept verbatim ([SCH-puzzle-def] F3/F4). Nothing is
## derived from F5, and nothing is validated beyond [SCH-puzzle-def] I1 — the
## loader owns the rest (specs/technical/components/pack.md R5).

## Field names as the loader hands them over ([SCH-puzzle-def] F2-F4).
const FIELD_SIZE := "size"
const FIELD_ROW_CLUES := "row_clues"
const FIELD_COL_CLUES := "col_clues"


## Builds the 2 × `size` lines from one definition record, or reports why it cannot.
static func from_definition(definition: Dictionary) -> ClueLinesResult:
	var size := _size_of(definition)
	var result := ClueLinesResult.new(size)
	if size <= 0:
		result.error = "%s is missing or not a positive integer: %s" % [FIELD_SIZE, definition.get(FIELD_SIZE)]
		return result

	for line_set in [FIELD_ROW_CLUES, FIELD_COL_CLUES]:
		var failure := _describe_line_set_failure(definition, line_set, size)
		if not failure.is_empty():
			result.error = failure
			return result

	var row_clues: Array = definition[FIELD_ROW_CLUES]
	var col_clues: Array = definition[FIELD_COL_CLUES]
	for index in size:
		result.lines.append(ClueLine.new(ClueLine.Orientation.ROW, index, _runs(row_clues[index])))
	for index in size:
		result.lines.append(ClueLine.new(ClueLine.Orientation.COLUMN, index, _runs(col_clues[index])))
	return result


static func _size_of(definition: Dictionary) -> int:
	if not definition.has(FIELD_SIZE):
		return 0
	var size = definition[FIELD_SIZE]
	if not (size is int or size is float):
		return 0
	return int(size)


# [SCH-puzzle-def] I1: F3 and F4 each contain `size` lists. Neither padding nor
# truncation is silent — the mismatch is the mapping error.
static func _describe_line_set_failure(definition: Dictionary, field: String, size: int) -> String:
	if not definition.has(field):
		return "%s is missing" % field
	var line_set = definition[field]
	if not line_set is Array:
		return "%s is not a list" % field
	if line_set.size() != size:
		return "%s has %s lines, expected %s" % [field, line_set.size(), size]
	return ""


static func _runs(line) -> Array[int]:
	var runs: Array[int] = []
	if not line is Array:
		return runs
	for run in line:
		runs.append(int(run))
	return runs
