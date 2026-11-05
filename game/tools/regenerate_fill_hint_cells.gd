extends SceneTree
## One-off pack write: recompute the [SCH-puzzle-def] F8 / F9 fill-hint cells for every
## entry of `res://data/pack.json` and rewrite the pack. Run with:
## `godot --headless --path game -s res://tools/regenerate_fill_hint_cells.gd`.
##
## F8 is each cell forced by single-line deduction: for one row or one column, its runs
## alone decide which cells are a fill in every valid arrangement of the line (fill) or
## in none (cross); F8 is that decision, unioned over all lines. F9 is the one-level
## result: the F8 marks act as known cell states, every line is solved again among the
## arrangements compatible with them, and cells forced by that second pass that F8 does
## not already hold are F9 ([I8]: disjoint by construction here and by validation at
## load). Nothing below derives cells during play ([b]CTR-pack[/b] G6); this tool is
## the only pack-time derivation, run when the pack is built or amended.

## The file this tool rewrites ([b]CTR-pack[/b] pack layout).
const PACK_PATH := "res://data/pack.json"

## The forced marks a cell may carry ([SCH-puzzle-def] F8, F9).
const FILL := "fill"
const CROSS := "cross"


func _init() -> void:
	var text := FileAccess.get_file_as_string(PACK_PATH)
	var open_error := FileAccess.get_open_error()
	if open_error != OK or text.is_empty():
		push_error("Pack file missing or unreadable: %s" % PACK_PATH)
		quit(1)
		return
	var json := JSON.new()
	if json.parse(text) != OK:
		push_error("Pack file is not valid JSON: %s" % json.get_error_message())
		quit(1)
		return
	var entries: Variant = json.data
	if typeof(entries) != TYPE_ARRAY:
		push_error("Pack file is not a JSON array")
		quit(1)
		return
	var rewritten: Array = []
	for index in entries.size():
		var entry: Dictionary = entries[index]
		rewritten.append(_with_hint_cells(entry))
	_write_pack(rewritten)
	print("Rewrote %s: %d entries carry F8/F9 fill-hint cells" % [PACK_PATH, rewritten.size()])
	quit(0)


## [param entry] with its F8 and F9 lists computed from its clues and solution fills.
func _with_hint_cells(entry: Dictionary) -> Dictionary:
	var size: int = entry["size"]
	var fills: Dictionary = {}
	for cell: Variant in entry["solution-fills"]:
		fills[Vector2i(cell[0], cell[1])] = true
	var single: Dictionary = _union_forced(entry["row-clues"], entry["col-clues"], size, {})
	var single_map: Dictionary = single
	var multi_map: Dictionary = {}
	if not single_map.is_empty():
		var multi: Dictionary = _union_forced(
			entry["row-clues"], entry["col-clues"], size, single_map
		)
		for position: Variant in multi:
			if not single_map.has(position):
				multi_map[position] = multi[position]
	entry["single-fill-hint-cells"] = _to_cells(single_map, fills)
	entry["multi-fill-hint-cells"] = _to_cells(multi_map, fills)
	return entry


## Every forced mark over both line directions. [param known] holds the F8 marks that
## constrain the second pass ([SCH-puzzle-def] F9); raise on a contradiction so no
## silent wrong cell ships.
func _union_forced(
	row_clues: Array,
	col_clues: Array,
	size: int,
	known: Dictionary,
) -> Dictionary:
	var forced: Dictionary = {}
	for row in size:
		var marks: Dictionary = _line_forced(row_clues[row], size, row, true, known)
		_absorb(forced, marks, "row %d" % row)
	for column in size:
		var marks: Dictionary = _line_forced(col_clues[column], size, column, false, known)
		_absorb(forced, marks, "column %d" % column)
	return forced


## The forced cells of one line: run lengths [param runs] against the line's known
## states; [param by_row] says whether line index [param index] selects a row or column
## position ([SCH-puzzle-def] F3, F4).
func _line_forced(
	runs: Variant,
	size: int,
	index: int,
	by_row: bool,
	known: Dictionary,
) -> Dictionary:
	var solver := _LineSolver.new()
	solver.runs = []
	for run: Variant in runs:
		solver.runs.append(int(run))
	solver.length = size
	solver.known.clear()
	for step in size:
		var position := Vector2i(index, step) if by_row else Vector2i(step, index)
		if known.has(position):
			solver.known[step] = known[position]
	solver.solve()
	if solver.total == 0:
		push_error(
			(
				"No valid arrangement for %s %d with the known marks; the pack is inconsistent"
				% ["row" if by_row else "column", index]
			)
		)
		quit(1)
		return {}

	var marks: Dictionary = {}
	for step in size:
		var position := Vector2i(index, step) if by_row else Vector2i(step, index)
		if solver.fill_counts[step] == solver.total:
			marks[position] = FILL
		elif solver.fill_counts[step] == 0:
			marks[position] = CROSS
	return marks


## Merge [param marks] into [param forced]; both lines forcing the same cell must force
## the same mark, since the true solution satisfies every line.
func _absorb(forced: Dictionary, marks: Dictionary, where: String) -> void:
	for position: Variant in marks:
		var mark: String = marks[position]
		if forced.has(position) and forced[position] != mark:
			push_error(
				(
					"%s forces %s as %s but another line says %s"
					% [where, position, mark, forced[position]]
				)
			)
			quit(1)
			return
		forced[position] = mark


## The sorted [param marks] as `[row, column, mark]` triples, row-major order.
func _to_cells(marks: Dictionary, fills: Dictionary) -> Array:
	var positions: Array = marks.keys()
	positions.sort()
	var cells: Array = []
	for position: Variant in positions:
		var vector: Vector2i = position
		if marks[vector] == FILL and not fills.has(vector):
			push_error("Fill hint at %s is not a solution fill" % vector)
			quit(1)
			return []
		cells.append([vector.x, vector.y, marks[vector]])
	return cells


## The whole array of [param entries] as one line per entry with blank lines between
## them, matching the layout the pack already uses so the diff stays data-only.
func _write_pack(entries: Array) -> void:
	var lines: PackedStringArray = []
	for index in entries.size():
		var line := JSON.stringify(entries[index])
		if index < entries.size() - 1:
			line += ","
		lines.append(line)
	var text := "[\n\n%s\n]\n" % "\n\n".join(lines)
	var file := FileAccess.open(PACK_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write pack file: %s" % PACK_PATH)
		quit(1)
		return
	file.store_string(text)
	file.close()


## Enumeration over every valid arrangement of one line's runs against known states
## ([SCH-puzzle-def] F8, F9). Counts per cell how many arrangements fill it
## ([member fill_counts]; equal to [member total] means forced fill, zero means forced
## cross). Solved headless, never during play ([b]CTR-pack[/b] G6).
class _LineSolver:
	extends RefCounted

	## -1 unset, 0 crosses this arrangement, 1 fills it.
	const EMPTY_MARK := -1

	## One run length per run of the line ([SCH-puzzle-def] F3, F4).
	var runs: Array[int] = []
	## Cell count of the line ([SCH-puzzle-def] F2).
	var length: int = 0
	## Cell index to the forced mark that constrains this pass, empty for the F8 pass.
	var known: Dictionary = {}
	## How many valid arrangements fill each cell index.
	var fill_counts: Array[int] = []
	## How many valid arrangements the line has; zero is a pack defect.
	var total := 0

	## Count the arrangements and record per-cell fill counts.
	func solve() -> void:
		fill_counts.clear()
		fill_counts.resize(length)
		fill_counts.fill(0)
		total = 0
		var state: Array[int] = []
		state.resize(length)
		state.fill(EMPTY_MARK)
		_place(0, 0, state)

	## Place run [param run_index] at or after cell [param minimum] on a [param state]
	## snapshot, then recurse; with no run left the line closes over the remaining
	## cells as empty, which also solves an empty clue. Only a fully placed line counts.
	func _place(run_index: int, minimum: int, state: Array[int]) -> void:
		if run_index == runs.size():
			var ok := true
			for step in range(minimum, length):
				if known.get(step, "") == FILL:
					ok = false
					break
				state[step] = 0
			if ok:
				total += 1
				for step in length:
					if state[step] == 1:
						fill_counts[step] += 1
			return
		var tail := 0
		for step in range(run_index, runs.size()):
			tail += runs[step]
			if step < runs.size() - 1:
				tail += 1
		for start in range(minimum, length - tail + 1):
			var line := state.duplicate()
			var ok := true
			for step in range(minimum, start):
				if known.get(step, "") == FILL:
					ok = false
					break
				line[step] = 0
			if not ok:
				continue
			for step in range(start, start + runs[run_index]):
				if known.get(step, "") == CROSS:
					ok = false
					break
				line[step] = 1
			if not ok:
				continue
			if run_index == runs.size() - 1:
				for step in range(start + runs[run_index], length):
					if known.get(step, "") == FILL:
						ok = false
						break
					line[step] = 0
				if ok:
					total += 1
					for step in length:
						if line[step] == 1:
							fill_counts[step] += 1
				continue
			if known.get(start + runs[run_index], "") == FILL:
				continue
			line[start + runs[run_index]] = 0
			_place(run_index + 1, start + runs[run_index] + 1, line)
