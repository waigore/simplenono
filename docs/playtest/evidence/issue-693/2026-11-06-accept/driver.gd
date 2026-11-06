extends SceneTree
## Headless acceptance playtest driver for issue #693 (gallery incomplete-only filter,
## `PTU-gallery-layout`, `PTU-gallery-reset`, `PTU-settings`). Drives the real shell
## with player-facing control signals and debug seams (`DBG.2`, `DBG.3`), and prints
## one `RESULT <id> <pass|fail> <detail>` line per judged point. No product code.

const SHELL := "res://presentation/shell.tscn"

var _shell: Shell


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var out: Array[String] = []
	# C5's control draws by kind, so the first frame's state needs a cross-frame read.
	await _boot_frames()
	var gallery := _shell.gallery_screen()
	out.append(
		"RESULT default-off %s stored=%s shown=%s hint=%s"
		% [
			_pass(not gallery.incomplete_only()),
			str(GalleryPreferences.stored()),
			str(gallery.incomplete_only()),
			gallery.get_node("%FilterHint").text
		]
	)
	var filter_button := gallery.filter_button()
	out.append(
		"RESULT c5-present %s text=%s focus_mode=%d"
		% [_pass(filter_button.is_visible_in_tree()), filter_button.text, filter_button.focus_mode]
	)

	# Fixture: solve pack-000 through the player's own attempt path so it is
	# ever-completed, then leave the puzzle and return to the gallery. A fresh
	# `user://` has no accepted progress, so the filter would otherwise hide nothing.
	var target_id := "pack-000"
	var fixture_seen := false
	_shell.open_puzzle(target_id)
	await _frames(3)
	await _solve_open()
	# UI-result's C1 (`NAV.T5`) refuses until the morph reaches `S1` (US1.5b): wait out
	# the beat and the morph stages the way the integration driver does.
	var morph_ms := int(ProjectSettings.get_setting(Shell.MORPH_STAGE_SETTING, 300))
	await process_frame
	await create_timer(3.0 * float(morph_ms) / 1000.0 + 0.4).timeout
	await _frames(3)
	var solved_view := _shell.view()
	_shell.close_result()
	await _frames(4)
	if _shell.view() == Shell.RESULT_VIEW:
		_shell.close_result()
		await _frames(10)
	var after := Pack.new()
	after.load_pack(Pack.PACK_PATH)
	for entry in after.list_entries():
		if entry.id == target_id and entry.ever_completed:
			fixture_seen = true
	gallery = _shell.gallery_screen()
	out.append(
		"RESULT fixture-completed %s id=%s solved_view=%s view=%s tiles=%d"
		% [
			_pass(fixture_seen),
			target_id,
			solved_view,
			_shell.view(),
			gallery.tile_count()
		]
	)
	# Second fixture for C2's box: start pack-001, mark one cell through Attempt, and leave.
	# A mark makes the attempt in progress, so its tile carries C2 Reset and the filter
	# keeps it (only ever-completed puzzles hide).
	var other_id := "pack-001"
	_shell.open_puzzle(other_id)
	await _frames(3)
	await _start_open()
	_shell.leave_puzzle()
	await _frames(4)
	var started := Pack.new()
	started.load_pack(Pack.PACK_PATH)
	var in_progress := false
	for entry in started.list_entries():
		if entry.id == other_id and entry.in_progress:
			in_progress = true
	out.append(
		"RESULT fixture-in-progress %s id=%s in_progress=%s"
		% [_pass(in_progress), other_id, str(in_progress)]
	)

	# AC 3, 4, 5: off lists all 200; on hides ever-completed in place; off again shows all.
	var count_off := gallery.tile_count()
	filter_button.emit_signal("pressed")
	await _frames(3)
	var hidden_ok := true
	for entry in gallery.entries():
		if entry.ever_completed and gallery.tile(entry.id) != null:
			hidden_ok = false
	out.append(
		"RESULT toggle-on-in-place %s view=%s tiles=%d->%d hint=%s"
		% [
			_pass(gallery.incomplete_only() and gallery.tile_count() < count_off),
			_shell.view(),
			count_off,
			gallery.tile_count(),
			gallery.get_node("%FilterHint").text
		]
	)
	out.append(
		"RESULT completed-hidden %s visible=%d of %d ids=%s"
		% [
			_pass(hidden_ok),
			gallery.tile_count(),
			gallery.pack_size(),
			str(gallery.tile(target_id) == null)
		]
	)
	var focus_ok := true
	for control in _shell.focus_controls():
		if control is GalleryTile and not control.visible:
			focus_ok = false
	out.append(
		"RESULT focus-skips-hidden %s focusables=%d"
		% [_pass(focus_ok), _shell.focus_controls().size()]
	)
	filter_button.emit_signal("pressed")
	await _frames(3)
	out.append(
		"RESULT toggle-off-in-place %s tiles=%d matches-pack=%s"
		% [
			_pass(not gallery.incomplete_only() and gallery.tile_count() == count_off),
			gallery.tile_count(),
			str(gallery.tile_count() == gallery.pack_size())
		]
	)

	# AC 2: toggle on through C5, then a cold relaunch in a child reads the store.
	filter_button.emit_signal("pressed")
	await _frames(3)
	out.append(
		"RESULT stored-on %s stored=%s in-memory=%s"
		% [
			_pass(GalleryPreferences.stored()),
			str(GalleryPreferences.stored()),
			str(gallery.incomplete_only())
		]
	)
	var relaunch := _relaunch_child()
	out.append(relaunch)
	out.append(_relaunch_child())

	# PTU-gallery-reset with the filter on: pack-000 is ever-completed and hidden, and a
	# reset must make it reappear without leaving the gallery.
	var seams := _shell.get_node("%Seams") as DebugSeams
	var reset_ok := false
	if fixture_seen and gallery.incomplete_only():
		# PTU-gallery-reset: reset while the filter is on brings the tile back.
		reset_ok = seams.reset_puzzle(target_id)
		gallery.refresh()
		await _frames(2)
		out.append(
			"RESULT reset-reappears %s id=%s reset_ok=%s filter_on=%s tile=%s tiles=%d"
			% [
				_pass(
					reset_ok and gallery.tile(target_id) != null and gallery.incomplete_only()
				),
				target_id,
				str(reset_ok),
				str(gallery.incomplete_only()),
				str(gallery.tile(target_id) != null),
				gallery.tile_count()
			]
		)
		# EX.confirm blocks C5; Cancel releases it with no write.
		var confirm_id := other_id
		var shown := gallery.present_reset_confirm(confirm_id)
		await _frames(4)
		var reset_live := gallery.tile(target_id) != null and gallery.tile(target_id).reset_allowed()
		out.append(
			"RESULT confirm-blocks-c5 %s shown=%s disabled=%s reset_live=%s"
			% [
				_pass(shown and filter_button.disabled),
				str(shown),
				str(filter_button.disabled),
				str(reset_live)
			]
		)
		gallery.dismiss_reset_confirm()
		await _frames(4)
		out.append(
			"RESULT confirm-releases-c5 %s disabled=%s filter_on=%s"
			% [
				_pass(not filter_button.disabled and gallery.incomplete_only()),
				str(filter_button.disabled),
				str(gallery.incomplete_only())
			]
		)
		# Cancel writes nothing: pack-000 is still not-ever-completed and still shown.
		var still_hidden := false
		for entry in gallery.entries():
			if entry.id == confirm_id:
				still_hidden = not entry.ever_completed
		out.append(
			"RESULT confirm-cancel-writes-nothing %s id=%s not_ever_completed=%s tile=%s"
			% [
				_pass(still_hidden and gallery.tile(confirm_id) != null),
				confirm_id,
				str(still_hidden),
				str(gallery.tile(confirm_id) != null)
			]
		)
		# Leave the filter on for the layout check.
		if not gallery.incomplete_only():
			filter_button.emit_signal("pressed")
			await _frames(2)

	# PTU-gallery-layout: chrome and grid fit at both test viewports with C5 shown.
	for size in [Vector2i(360, 640), Vector2i(640, 360)]:
		root.content_scale_size = size
		root.size = size
		await _frames(5)
		gallery = _shell.gallery_screen()
		var bar := gallery.get_node("Margin/Layout/FilterBar") as Control
		var block := gallery.get_node("Margin/Layout/ProgressBlock") as Control
		var fits := true
		for node in [block, bar]:
			var rect: Rect2 = (node as Control).get_global_rect()
			if rect.position.x < -0.5 or rect.end.x > float(size.x) + 0.5:
				fits = false
		out.append(
			"RESULT layout-%dx%d %s columns=%d margin=%.1f bar_x=%.1f..%.1f hint=%s"
			% [
				size.x,
				size.y,
				_pass(fits),
				gallery.columns(),
				gallery.page_margin(),
				bar.get_global_rect().position.x,
				bar.get_global_rect().end.x,
				gallery.get_node("%FilterHint").text
			]
		)
	root.content_scale_size = Vector2i(0, 0)
	root.size = Vector2i(390, 844)
	await _frames(3)

	# PTU-settings untouched by the new row: settings -> Back -> gallery. Leave any
	# result screen first through its own C1 route (a wait for the morph when needed).
	if _shell.view() == Shell.RESULT_VIEW:
		var morph_wait := int(ProjectSettings.get_setting(Shell.MORPH_STAGE_SETTING, 300))
		await create_timer(3.0 * float(morph_wait) / 1000.0 + 0.4).timeout
		_shell.close_result()
		await _frames(4)
	if _shell.view() == Shell.PUZZLE_VIEW:
		_shell.leave_puzzle()
		await _frames(4)
	elif _shell.view() == Shell.GALLERY_VIEW:
		_shell.open_menu()
		await _frames(3)
		if _shell.view() == Shell.MENU_VIEW:
			_shell.menu_screen().puzzles_requested.emit()
			await _frames(3)
	var opened := _shell.open_settings()
	await _frames(2)
	var showing := _shell.view() == Shell.SETTINGS_VIEW
	_shell.settings_screen().back_requested.emit()
	await _frames(2)
	out.append(
		"RESULT settings-back %s opened=%s back_to=%s"
		% [
			_pass(opened and showing and _shell.view() == Shell.GALLERY_VIEW),
			str(opened),
			_shell.view()
		]
	)
	out.append(
		"RESULT empty-state-copy copy=%s"
		% gallery.get_node("%EmptyLabel").text
	)

	for line in out:
		print(line)
	quit(0)


func _boot_frames() -> void:
	_shell = (load(SHELL) as PackedScene).instantiate() as Shell
	root.add_child(_shell)
	await _frames(3)
	if _shell.view() == Shell.MENU_VIEW:
		_shell.menu_screen().puzzles_requested.emit()
		await _frames(4)


## Ends the get-set-ready beat and marks one solution cell, leaving an in-progress
## attempt the way a player starts one.
func _start_open() -> void:
	var attempt := _shell.attempt()
	if attempt == null or attempt.definition() == null:
		return
	if attempt.get_set_ready():
		attempt.end_get_set_ready()
		await _frames(2)
	if not attempt.definition().solution_fills.is_empty():
		var cell := attempt.definition().solution_fills[0]
		var result := attempt.mark(cell.x, cell.y, CellMark.Mark.FILL)
		if result != null and _shell.puzzle_screen() != null:
			_shell.puzzle_screen().show_mark_result(result)
	await _frames(2)


## Fills the open puzzle's solution cells through Attempt, one per frame, as a player
## solving it would; the attempt's own commit path records progress.
func _solve_open() -> void:
	var attempt := _shell.attempt()
	if attempt == null or attempt.definition() == null:
		return
	if attempt.get_set_ready():
		attempt.end_get_set_ready()
		await _frames(2)
	for cell in attempt.definition().solution_fills:
		if attempt.state() == null:
			break
		var result := attempt.mark(cell.x, cell.y, CellMark.Mark.FILL)
		if result != null and _shell.puzzle_screen() != null:
			_shell.puzzle_screen().show_mark_result(result)
		await process_frame
	await _frames(2)


## One cold relaunch: a child process reads the stored F7 before drawing the gallery.
func _relaunch_child() -> String:
	var code := (
		"extends SceneTree\n"
		+ "func _init() -> void:\n"
		+ "	var stored := GalleryPreferences.stored()\n"
		+ "	var prefs := GalleryPreferences.new()\n"
		+ "	var shown := prefs.apply().incomplete_only()\n"
		+ "	print(\"CHILD stored=%s shown=%s\" % [str(stored), str(shown)])\n"
		+ "	quit(0)\n"
	)
	var path := "user://relaunch_check_693.gd"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(code)
	file.close()
	var output: Array = []
	var status := OS.execute(
		OS.get_executable_path(), ["--headless", "--path", ".", "-s", path], output, true
	)
	var text := "".join(output).strip_edges().replace("\n", " | ")
	var ok := status == 0 and text.contains("stored=true") and text.contains("shown=true")
	return "RESULT relaunch-on %s exit=%d %s" % [_pass(ok), status, text]


## The first id in [param gallery]'s pack that reads ever-completed.
func _first_ever_completed(gallery: GalleryScreen) -> String:
	for entry in gallery.entries():
		if entry.ever_completed:
			return entry.id
	return ""


func _frames(count: int) -> void:
	for i in count:
		await process_frame


func _pass(condition: bool) -> String:
	return "pass" if condition else "fail"
