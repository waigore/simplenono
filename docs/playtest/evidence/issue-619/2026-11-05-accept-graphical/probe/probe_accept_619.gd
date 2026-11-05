extends SceneTree
## Graphical acceptance capture for #619 (copied into `game/` for the run, removed after).
##
## The deliverable (PR #625) lays each row clue number out at its glyph width so the
## number is drawn, and dims each clue number on its own: a number dims when the
## line's fill island at its position exists and has that number's exact length
## ([code]E-clue[/code] P4/I4, [code]GS.clue-num-matched[/code]); the whole board is
## re-derived after every mark, line error still outranks the dim, and an all-empty line
## dims with its aggregate ([code]E-clue[/code] P3/I3, [code]GS.clue-satisfied[/code]).
##
## Protocol: [code]PTD-clue-dim[/code] S1-S5 / P1-P4
## ([code]specs/playtest/design/clue-dim.md[/code]).
##
## Fixture: `pack-000` ([code]DBG.3[/code]) - row 6 is `6 2`, row 7 is `3`, row 8 is
## `1 4`, rows 0-1 have no clue, columns 0 is `1 1` and column 6 is `3 2`.
##
## Judged states (every clue label read from the drawn board after a real pointer mark):
##
##   `01-prefix-mixed`        row 8 `1 4` with one fill: `1` dim, `4` highlighted
##   `02-break-undim`         row 7 `3` exactly filled then the island cleared down to two:
##                            that number returns to highlighted while column 5 `3 1`
##                            stays dimmed
##   `03-error-over-dim`      row 8 island `1` still matches but the line contradicts:
##                            contradiction colour replaces the dim
##   `04-incomplete-island`   row 7 `3` with two fills: stays highlighted, no line error
##   `05-column-prefix`       column 6 `3 2` with one island of three: `3` dim, `2` highlighted
##   `06-cross-splits`        a cross between the islands: `3 2` both dim, the cross is not
##                            a fill
##   `07-full-line`           row 6 `6 2` exactly realized: both numbers dim
##   `08-reopened-cue`        the `01` cue reached through C1 leave and the gallery tile
##
##     godot --path game -s res://probe_accept_619.gd -- --debug-seams \
##         --session-id=issue-619-accept --build-id=main@<sha> \
##         --story-ids=PTD-clue-dim --shot-dir=<run>/screenshots --run-folder=<run>

const SHELL_SCENE := preload("res://presentation/shell.tscn")
const SHOT_DIR_ARG := "--shot-dir="
const RUN_FOLDER_ARG := "--run-folder="
const PUZZLE := "pack-000"

const REQUIRED_SHOTS := [
	"01-prefix-mixed",
	"02-break-undim",
	"03-error-over-dim",
	"04-incomplete-island",
	"05-column-prefix",
	"06-cross-splits",
	"07-full-line",
	"08-reopened-cue",
]

var _shell: Shell
var _seams: DebugSeams
var _screen: PuzzleScreen
var _board: PuzzleBoard
var _shot_dir := ""
var _run_folder := ""
var _failures: Array[String] = []
var _shots_taken: Array[String] = []


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run_folder = _argument(RUN_FOLDER_ARG)
	if _shot_dir.is_empty() or _run_folder.is_empty():
		printerr("capture: --shot-dir and --run-folder are required")
		quit(2)
		return
	_run.call_deferred()


func _run() -> void:
	if not DebugSeams.is_enabled():
		printerr("capture: the debug seams are off. Relaunch with --debug-seams.")
		quit(2)
		return
	root.size = Vector2i(900, 1200)
	_shell = SHELL_SCENE.instantiate()
	root.add_child(_shell)
	await _settle(3)
	_seams = _shell.get_node("%Seams") as DebugSeams
	_seams.set_story_ids(_story_ids())
	_seams.toggle_overlay()
	var accepted := _shell.pack().load_result().accepted_count
	var rejected := _shell.pack().load_result().rejected.size()
	print("capture: pack accepted=%d rejected=%d" % [accepted, rejected])

	await _prefix_and_break()
	await _break_undims()
	await _error_outranks_dim()
	await _incomplete_island()
	await _column_split()
	await _full_line()
	_finish()


## `PTD-clue-dim` S1 / S2, P1, P4: open a fresh board whose row 8 is `1 4` and column 0
## is `1 1`. One fill makes the first number of each match, so those dim and the next
## stays highlighted; the all-empty rows read satisfied and their glyph is dim.
func _prefix_and_break() -> void:
	await _fresh_open("prefix")
	_judge_empty_line(true, 0, "S1: row 0 has no clue and no fill")
	_judge_empty_line(true, 1, "S1: row 1 has no clue and no fill")
	await _click(8, 0)
	await _judge_line(true, 8, [true, false], "S2/P1: row 8 `1 4`, one fill")
	await _judge_line(false, 0, [true, false], "S2/P1: column 0 `1 1`, one fill")
	_judge_board("S2/P1: the whole board after the row 8 fill")
	await _shot("01-prefix-mixed")

	# Reached the way the player reaches it: C1 to the gallery, then the in-progress tile.
	var problems := await _reopen_via_gallery("reopen")
	var shown: Array = []
	for label in _line_labels(true, 8):
		shown.append(_color_name(_color(label)))
	_check(
		problems.is_empty() and shown == ["dim", "highlighted"],
		"reopen: the cue after C1 leave and the gallery tile reopen (%s, row 8 %s)"
		% [str(problems), str(shown)]
	)
	await _shot("08-reopened-cue")


## `PTD-clue-dim` S3 / P2 and `E-clue` PS1.2b: clearing a fill inside a matched island
## returns that number to highlighted on the whole-board re-evaluation, while a line
## elsewhere that still matches keeps its numbers dimmed.
func _break_undims() -> void:
	await _fresh_open("break")
	# A completed column island elsewhere: column 5 `3 1` holds its three.
	await _click(0, 5)
	await _click(1, 5)
	await _click(2, 5)
	await _judge_line(false, 5, [true, false], "S3/P2: column 5 `3 1`, island of three")
	# Row 7 `3`: its island exactly fills, so its number dims.
	await _click(7, 0)
	await _click(7, 1)
	await _click(7, 2)
	await _judge_line(true, 7, [true], "S3/P2: row 7 `3`, exactly filled")
	# Clear the first fill of that island: the island shrinks and the number un-dims.
	await _click(7, 0)
	await _judge_line(true, 7, [false], "S3/P2: row 7 `3`, island of two after the clear")
	await _judge_line(false, 5, [true, false], "S3/P2: column 5 still matches after the break elsewhere")
	_judge_board("S3/P2: the whole board after the break")
	await _shot("02-break-undim")


## `PTD-clue-dim` P1 with `E-clue` I2/I4: line error outranks the number cue, so a number
## whose island still matches reads as contradiction, not as dim, on a contradicting line.
func _error_outranks_dim() -> void:
	await _fresh_open("error")
	await _click(8, 0)
	await _judge_line(true, 8, [true, false], "P1/I2: row 8 `1 4`, island `1` matches")
	for column in [3, 4, 5, 6, 7]:
		await _click(8, column)
	var status := _screen.attempt().rules().line_status(_screen.attempt().state().marks())
	var islands := _island_lengths(true, 8)
	_check(
		islands.size() > 0 and islands[0] == 1,
		"P1/I2: row 8 island 0 is still the `1` of the clue (%s)" % str(islands)
	)
	_check(status.row(8).error, "P1/I2: row 8 contradicts its clue")
	await _judge_line(true, 8, [true, false], "P1/I2: row 8 with its island of five", true)
	_judge_board("P1: the whole board with row 8 in error")
	await _shot("03-error-over-dim")


## `PTD-clue-dim` P1: two fills toward a `3` are an incomplete island and stay
## highlighted, with no line error.
func _incomplete_island() -> void:
	await _fresh_open("incomplete")
	await _click(7, 0)
	await _click(7, 1)
	await _judge_line(true, 7, [false], "S2: row 7 `3`, two fills toward it")
	_judge_board("S2: the whole board after the incomplete island")
	await _shot("04-incomplete-island")


## `PTD-clue-dim` S2/S4, P1/P3: a column `3 2` whose first island of three dims only
## that number, then a cross after it and two fills: two islands, both numbers dim, and
## the cross did not count as a fill.
func _column_split() -> void:
	await _fresh_open("column")
	await _click(0, 6)
	await _click(1, 6)
	await _click(2, 6)
	await _judge_line(false, 6, [true, false], "S2/P1: column 6 `3 2`, island of three")
	_judge_board("S2/P1: the whole board after the column island")
	await _shot("05-column-prefix")

	await _cross(3, 6)
	await _judge_line(false, 6, [true, false], "S4/P3: the cross after the island keeps it three long")
	await _click(5, 6)
	await _click(6, 6)
	await _judge_line(false, 6, [true, true], "S4/P3/P4: column 6 `3 2`, islands three then two")
	_judge_board("S4/P4: the whole board after the column split")
	await _shot("06-cross-splits")


## `PTD-clue-dim` S5 / P4: a line whose fills exactly realize its clue dims every number,
## beside the all-empty rows that dim with their own aggregate.
func _full_line() -> void:
	await _fresh_open("full")
	for column in [0, 1, 2, 3, 4, 5, 8, 9]:
		await _click(6, column)
	await _judge_line(true, 6, [true, true], "S5/P4: row 6 `6 2`, exactly realized")
	_judge_board("S5/P4: the whole board after the full line")
	await _shot("07-full-line")


## Clears the puzzle's progress and reopens it, so each leg starts from a board with no
## marks ([code]DBG.3[/code] drives [code]CTR-attempt[/code] O1 on the reset record).
func _fresh_open(leg: String) -> void:
	_check(_seams.reset_puzzle(PUZZLE), "%s: DBG.3 fixture %s resets" % [leg, PUZZLE])
	_check(_shell.open_puzzle(PUZZLE), "%s: DBG.3 opens %s" % [leg, PUZZLE])
	_screen = _shell.puzzle_screen()
	_board = _screen.get_node("%Board") as PuzzleBoard
	await _settle(2)
	_screen.finish_ready_beat()
	await _settle(2)
	_check(_screen.state_id() == PuzzleScreen.STATE_READY, "%s: ready after the get-set-ready beat" % leg)
	_check(_screen.marks_allowed(), "%s: marks are allowed" % leg)
	for position in _filled_cells():
		_failures.append("%s: the fresh board already holds a fill at %s" % [leg, str(position)])
	_judge_board("%s: the fresh board" % leg)


## The same screen through the real path: leave to the gallery (C1) and reopen its tile.
func _reopen_via_gallery(state: String) -> Array[String]:
	var problems: Array[String] = []
	var leave := _screen.get_node("%LeaveButton") as Button
	await _send_click(leave.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _settle(3)
	if _shell.view() != Shell.GALLERY_VIEW:
		problems.append("%s: C1 Leave did not return to the gallery" % state)
	var tile := _shell.gallery_screen().tile(PUZZLE)
	if tile == null:
		problems.append("%s: %s has no gallery tile to reopen" % [state, PUZZLE])
		return problems
	if not tile.status_text().to_lower().contains("progress"):
		problems.append("%s: the tile reads '%s', not in progress" % [state, tile.status_text()])
	if not _shell.gallery_screen().activate_tile(PUZZLE):
		problems.append("%s: the gallery tile does not reopen the puzzle" % state)
		return problems
	await _settle(3)
	_screen = _shell.puzzle_screen()
	_board = _screen.get_node("%Board") as PuzzleBoard
	_screen.finish_ready_beat()
	await _settle(2)
	return problems


## Judges one numbered clue line's label colours against the expected match flags, one
## Boolean per clue number (true = dimmed). With [param contradicting] the line is in line
## error, so every number must read as contradiction instead (`E-clue` I4 precedence);
## otherwise the line must not be in error, so a highlighted number really reads Ink.
func _judge_line(
	is_row: bool, index: int, flags: Array, state: String, contradicting: bool = false
) -> void:
	var labels := _line_labels(is_row, index)
	var problems: Array[String] = []
	var status := _screen.attempt().rules().line_status(_screen.attempt().state().marks())
	var line_status := status.row(index) if is_row else status.column(index)
	if line_status.error != contradicting:
		problems.append(
			"%s: the line reads line error %s, expected %s"
			% [state, str(line_status.error), str(contradicting)]
		)
	if labels.size() != flags.size():
		problems.append(
			"%s: the line draws %d labels for %d clue numbers"
			% [state, labels.size(), flags.size()]
		)
	var wants: Array[Color] = []
	for number in min(labels.size(), flags.size()):
		var want: Color
		if contradicting:
			want = PresentationPalette.CONTRADICTION
		else:
			want = PresentationPalette.DIM if flags[number] else PresentationPalette.INK
		wants.append(want)
		if _color(labels[number]) != want:
			problems.append(
				(
					"%s: number %d reads %s, expected %s"
					% [state, number, _color_name(_color(labels[number])), _color_name(want)]
				)
			)
	var before := problems.size()
	problems.append_array(await _judge_drawn(labels, wants, state))
	if problems.size() == before:
		problems.append_array(await _judge_bar_drawn(labels[0] as Label, state))
	_report(is_row, index, state, problems)


## The clue bar itself must draw something: a clipped-away number leaves the whole bar
## blank (#602 acceptance, PR #612's row clue regression). Only [param label]'s own
## columns count, so the board's frame rule beside the bar is not mistaken for a glyph.
func _judge_bar_drawn(label: Label, state: String) -> Array[String]:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var columns := {}
	for y in range(max(0, int(label.get_global_rect().position.y)), min(image.get_height(), int(label.get_global_rect().end.y))):
		for x in range(max(0, int(label.get_global_rect().position.x)), min(image.get_width(), int(label.get_global_rect().end.x))):
			var pixel := image.get_pixel(x, y)
			if _ink_distance(pixel, PresentationPalette.PAPER) > 0.05:
				if _ink_distance(pixel, PresentationPalette.RULE) > 0.05:
					columns[x] = int(columns.get(x, 0)) + 1
	var widest := 0
	for x in columns:
		widest = maxi(widest, int(columns[x]))
	if widest < 4:
		return [
			(
				"%s: its glyph is not drawn (the label box holds %d non-background columns, widest %d px)"
				% [state, columns.size(), widest]
			)
		]
	return []


## The drawn cue, not just the label's colour override: the darkest glyph pixel of each
## number must be the expected colour, so the dim is visible on the frame that is
## screenshotted.
func _judge_drawn(labels: Array, wants: Array[Color], state: String) -> Array[String]:
	# The clue labels sit in containers, which sort on the next frame: let them settle so
	# the sampled rect is the one the screenshot shows.
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var problems: Array[String] = []
	for number in min(labels.size(), wants.size()):
		var label := labels[number] as Label
		var box := Rect2i(label.get_global_rect())
		if label.size.x < 8.0:
			problems.append(
				(
					"%s: number %d is laid out %.0f px wide in its clue bar, so its glyph is clipped and not drawn"
					% [state, number, label.size.x]
				)
			)
			continue
		var darkest := Color(1, 1, 1, 1)
		var count := 0
		for y in range(max(0, box.position.y), min(image.get_height(), box.end.y)):
			for x in range(max(0, box.position.x), min(image.get_width(), box.end.x)):
				var pixel := image.get_pixel(x, y)
				count += 1
				if _ink_distance(pixel, PresentationPalette.PAPER) > 0.05:
					if _luminance(pixel) < _luminance(darkest):
						darkest = pixel
		if count == 0:
			problems.append("%s: number %d is outside the frame" % [state, number])
		elif _ink_distance(darkest, wants[number]) > 0.06:
			problems.append(
				(
					"%s: number %d is drawn %s, expected %s"
					% [state, number, _color_name(darkest), _color_name(wants[number])]
				)
			)
	return problems


## Judges an all-empty clue line: one glyph, dim because the line reads satisfied.
func _judge_empty_line(is_row: bool, index: int, state: String) -> void:
	var labels := _line_labels(is_row, index)
	var runs := _line_runs(is_row, index)
	var problems: Array[String] = []
	if not runs.is_empty():
		problems.append("%s: the fixture line is not all-empty" % state)
	if labels.size() != 1:
		problems.append("%s: an all-empty line draws one glyph, got %d" % [state, labels.size()])
	for label in labels:
		if _color(label) != PresentationPalette.DIM:
			problems.append(
				"%s: the all-empty glyph reads %s, expected dim" % [state, _color_name(_color(label))]
			)
	_report(is_row, index, state, problems)


func _report(is_row: bool, index: int, state: String, problems: Array[String]) -> void:
	var labels := _line_labels(is_row, index)
	var runs := _line_runs(is_row, index)
	var observed: Array = []
	for label in labels:
		observed.append(_color_name(_color(label)))
	var where := "%s %d clues=%s observed=%s" % [
		"row" if is_row else "column", index, str(runs), str(observed)
	]
	if problems.is_empty():
		print("capture: PASS %s (%s)" % [state, where])
	else:
		for problem in problems:
			_failures.append(problem)
			printerr("capture: FAIL %s" % problem)
	print("capture: %s" % where)


## Every clue number on the whole board against an independent island walk over the
## marks (the label colours must say exactly what the rule says), so a stale or sticky
## cue anywhere is caught, not just on the judged line.
func _judge_board(state: String) -> void:
	var state_now := _screen.attempt().state()
	var status := _screen.attempt().rules().line_status(state_now.marks())
	for row in _definition().size:
		_judge_derived(true, row, status.row(row), state)
	for column in _definition().size:
		_judge_derived(false, column, status.column(column), state)


func _judge_derived(is_row: bool, index: int, status: LineStatus, state: String) -> void:
	var labels := _line_labels(is_row, index)
	var runs := _line_runs(is_row, index)
	var islands := _island_lengths(is_row, index)
	for number in labels.size():
		var want: Color
		if status.error:
			want = PresentationPalette.CONTRADICTION
		elif runs.is_empty():
			want = PresentationPalette.DIM if status.satisfied else PresentationPalette.INK
		else:
			var matched := number < islands.size() and islands[number] == int(runs[number])
			want = PresentationPalette.DIM if matched else PresentationPalette.INK
		if _color(labels[number]) != want:
			_failures.append(
				(
					"%s: %s %d number %d reads %s, the marks say %s"
					% [
						state,
						"row" if is_row else "column",
						index,
						number,
						_color_name(_color(labels[number])),
						_color_name(want),
					]
				)
			)


## The maximal runs of fills on one line, in line order; a clear and a cross both end
## one (`Fill island`, `E-clue` P4). This re-derives the cue without the rules code.
func _island_lengths(is_row: bool, index: int) -> Array[int]:
	var marks := _screen.attempt().state().marks()
	var islands: Array[int] = []
	var length := 0
	for step in _definition().size:
		var filled := (
			marks.mark_at(index, step) == CellMark.Mark.FILL
			if is_row
			else marks.mark_at(step, index) == CellMark.Mark.FILL
		)
		if filled:
			length += 1
		elif length > 0:
			islands.append(length)
			length = 0
	if length > 0:
		islands.append(length)
	return islands


func _filled_cells() -> Array[Vector2i]:
	var filled: Array[Vector2i] = []
	var marks := _screen.attempt().state().marks()
	for position in marks.filled_positions():
		filled.append(position)
	return filled


func _line_labels(is_row: bool, index: int) -> Array:
	var labels: Array = _board.row_clue_labels(index) if is_row else _board.column_clue_labels(index)
	var result: Array = []
	for label in labels:
		result.append(label)
	return result


func _line_runs(is_row: bool, index: int) -> Array:
	var definition := _definition()
	return definition.row_clues[index] if is_row else definition.col_clues[index]


func _row_labels(row: int) -> Array:
	return _line_labels(true, row)


func _definition() -> PuzzleDefinition:
	return _shell.pack().definition(PUZZLE)


func _color(label: Label) -> Color:
	return label.get_theme_color("font_color")


func _luminance(color: Color) -> float:
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b


func _ink_distance(a: Color, b: Color) -> float:
	return maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b)))


func _color_name(color: Color) -> String:
	if color == PresentationPalette.DIM:
		return "dim"
	if color == PresentationPalette.INK:
		return "highlighted"
	if color == PresentationPalette.CONTRADICTION:
		return "contradiction"
	return str(color)


func _click(row: int, column: int) -> void:
	await _send_click(_cell_center(row, column), MOUSE_BUTTON_LEFT)
	await _settle(2)


func _cross(row: int, column: int) -> void:
	await _send_click(_cell_center(row, column), MOUSE_BUTTON_RIGHT)
	await _settle(2)


func _cell_center(row: int, column: int) -> Vector2:
	return _board.cell_at(row, column).get_global_rect().get_center()


func _send_click(position: Vector2, button_index: MouseButton) -> void:
	# A real pointer goes through Input's action map (MarkInput reads
	# `InputEventMouseButton.is_action_pressed("in_activate")`), which only exists
	# after the event was parsed in its own frame. The release is held for a frame so
	# `Input.is_action_pressed` is false when the handler sees it, then parsed.
	Input.warp_mouse(position)
	await process_frame
	var press := InputEventMouseButton.new()
	press.button_index = button_index
	press.pressed = true
	press.position = position
	press.global_position = position
	Input.parse_input_event(press)
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = button_index
	release.pressed = false
	release.position = position
	release.global_position = position
	Input.parse_input_event(release)
	await process_frame
	await process_frame


func _check(condition: bool, label: String) -> void:
	if condition:
		print("capture: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("capture: FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print("capture: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _finish() -> void:
	for shot in REQUIRED_SHOTS:
		if not _shots_taken.has(shot):
			_failures.append("the run never reached '%s', so its state was not judged" % shot)
	if _seams != null:
		print("capture: state dump %s" % _seams.dump_state(_run_folder))
	if _failures.is_empty():
		print("capture: RESULT pass (%d shots, 0 checks failed)" % _shots_taken.size())
		quit(0)
	else:
		for failure in _failures:
			printerr("capture: FAILED %s" % failure)
		print("capture: RESULT fail (%d failures)" % _failures.size())
		quit(1)


func _story_ids() -> Array[String]:
	var ids: Array[String] = []
	for value in _argument("--story-ids=").split(",", false):
		ids.append(value.strip_edges())
	return ids


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
