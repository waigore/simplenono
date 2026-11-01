## Issue #218 acceptance playtest — PTU-play-puzzle + UI-result US1.1-US1.5.
##
## Runs the acceptance build through the real shell, real screens, real controls and real
## engine frames, including the reveal's own clock. Copied into game/ for the run and
## removed after; no product code is changed.
##
##     godot --path game -s res://probe_accept_218.gd -- --shot-dir=<run>/screenshots
##     godot --headless --path game -s res://probe_accept_218.gd -- [--no-shots]
extends SceneTree

const SHOT_DIR_ARG := "--shot-dir="
const SHELL_SCENE := preload("res://presentation/shell.tscn")
const PUZZLE_ID := "pack-000"


var _shell: Shell
var _shot_dir := ""
var _shots_taken: Array[String] = []
var _failures: Array[String] = []
var _checks := 0


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(900, 1400)
	_shell = SHELL_SCENE.instantiate()
	root.add_child(_shell)
	await _settle(4)

	print("probe218: build view=%s" % _shell.view())

	# ------------------------------------------------------------ PTU-play-puzzle
	# S1: open a not-started puzzle from UI-gallery.
	_check(_shell.view() == Shell.GALLERY_VIEW, "PTU-play-puzzle S1: start on UI-gallery")
	_shell.pack().progress().reset(PUZZLE_ID)
	_shell.gallery_screen().refresh()
	await _settle(2)
	var tile := _shell.gallery_screen().tile(PUZZLE_ID)
	_check(tile != null, "PTU-play-puzzle S1: gallery offers a tile for %s" % PUZZLE_ID)
	if tile == null:
		_finish()
		return
	_check(tile.status_text() == GalleryTile.COPY_STATUS_NOT_STARTED,
		"PTU-play-puzzle P2 setup: %s reads not started before the run" % PUZZLE_ID)
	await _shot("p0-gallery-before-play")

	tile.activate()
	await _settle(3)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "PTU-play-puzzle S1: tile C1 opens UI-puzzle")

	# S2: the get-set-ready beat, then marks are allowed.
	var screen := _shell.puzzle_screen()
	_check(not screen.marks_allowed(), "PTU-play-puzzle S2: the beat blocks marks first")
	await _shot("p1-puzzle-get-set-ready")
	screen.finish_ready_beat()
	await _settle(3)
	_check(screen.marks_allowed(), "PTU-play-puzzle S2: marks are allowed after ready")
	await _shot("p2-puzzle-marks-allowed")

	# S3: stage every fill but the last, then place it.
	var definition := _shell.pack().definition(PUZZLE_ID)
	_check(definition != null, "PTU-play-puzzle S3: the pack serves %s" % PUZZLE_ID)
	if definition == null:
		_finish()
		return
	var fills: Array[Vector2i] = []
	for cell in definition.solution_fills:
		fills.append(cell)
	var last := fills[fills.size() - 1]
	for cell in fills:
		if cell == last:
			continue
		_shell.attempt().mark(cell.x, cell.y, CellMark.Mark.FILL)
	# The screen redraws through refresh(); a direct attempt().mark() bypasses it.
	screen.refresh()
	await _settle(2)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "PTU-play-puzzle US1.4b: a partial grid stays on UI-puzzle")
	_check(_shell.attempt().state().marks().filled_positions().size() == fills.size() - 1,
		"PTU-play-puzzle US1.4b: %d fills staged and drawn before the last" % (fills.size() - 1))
	await _shot("p3-puzzle-one-fill-left")

	var solved := [false]
	_shell.attempt().solved.connect(func(_id: String, _elapsed: int) -> void: solved[0] = true)
	_shell.attempt().mark(last.x, last.y, CellMark.Mark.FILL)
	await _settle(2)
	_check(solved[0], "PTU-play-puzzle S3 / END.W1: the last fill solves the puzzle")
	_check(_shell.view() == Shell.RESULT_VIEW, "PTU-play-puzzle S3: the solve opens UI-result")
	var result := _shell.result_screen()
	var reveal := result.reveal()

	# US1.1: opens on the fills, no controls.
	_check(result.is_morphing(), "UI-result US1.1: the morph is running on open")
	_check(not result.can_go_back(), "UI-result US1.1 / US1.3: no controls during the morph")
	_check(reveal.stage() == ResultReveal.STAGE_PIXEL, "UI-result US1.1: the morph opens on S2")
	await _shot("p4-result-morph-start")

	# Watch the whole chain on real frames: sample every frame for emptiness and stage.
	var start_us := Time.get_ticks_usec()
	var frames := 0
	var empty_frames := 0
	var samples: Array[String] = []
	var last_stage := ""
	while result.is_morphing() and frames < 900:
		await process_frame
		frames += 1
		var stage := reveal.stage()
		var drawable := _drawable_layers(reveal)
		if drawable == 0:
			empty_frames += 1
			samples.append("EMPTY@%dms stage=%s" % [frames, stage])
		elif stage != last_stage:
			samples.append("%dms stage=%s drawable=%s fills=%.3f pixel=%.3f picture=%.3f"
				% [frames, stage, drawable,
					reveal.fills_slot().opacity(), reveal.pixel_slot().opacity(), reveal.picture_slot().opacity()])
		last_stage = stage
	var elapsed_ms := float(Time.get_ticks_usec() - start_us) / 1000.0
	var stage_ms := reveal.stage_ms()
	print("probe218: morph reached %s in %.1f ms over %d real frames (2 x stage = %d ms)"
		% [result.stage(), elapsed_ms, frames, 2 * stage_ms])
	print("probe218: chain sample: %s" % " | ".join(samples))
	print("probe218: empty frames across the chain: %d" % empty_frames)

	_check(elapsed_ms > 2.0 * stage_ms * 0.75,
		"UI-result US1.2: the morph spends both stages (%d ms, 2 x %d)" % [int(elapsed_ms), stage_ms])
	_check(result.stage() == ResultReveal.STAGE_DEFAULT, "UI-result US1.2: the morph finishes at S1 Default")
	_check(not result.is_morphing(), "UI-result US1.2: nothing is morphing after both stages")

	# US1.5 / S1: this build ships no stored pictures, so the best shipped layer must be visible.
	var drawable_at_default := _drawable_layers(reveal)
	_check(drawable_at_default >= 1, "UI-result US1.5 / S1: a drawable layer is visible at Default (%d)" % drawable_at_default)
	_check(reveal.fills_slot().has_content(),
		"UI-result US1.5: the solved fills are the best shipped layer in this build (fill_count=%d)" % reveal.fills_slot().fill_count())
	_check(reveal.fills_slot().opacity() > 0.99, "UI-result US1.5: that layer is at full opacity at Default")
	_check(reveal.picture_slot().opacity() < 0.01 and reveal.pixel_slot().opacity() < 0.01,
		"UI-result US1.5: the absent picture layers are not what S1 shows")
	_check(empty_frames == 0, "UI-result US1.5: no frame between S2 and S1 is empty")
	_check(result.back_text() == ResultScreen.COPY_BACK, "UI-result US1.2 R2: C1 reads %s" % ResultScreen.COPY_BACK)
	_check(result.can_go_back(), "UI-result US1.2: C1 Back is available at Default")
	await _shot("p5-result-default")

	# S4: Back with UI-result.C1.
	var back_button := result.back_button()
	_check(back_button != null, "PTU-play-puzzle S4: the result shows its C1 control")
	if back_button != null:
		back_button.pressed.emit()
	await _settle(3)
	_check(_shell.view() == Shell.GALLERY_VIEW, "PTU-play-puzzle S4: C1 returns to UI-gallery")
	_check(_shell.result_screen().visible == false or _shell.view() == Shell.GALLERY_VIEW,
		"PTU-play-puzzle P1 / US1.2b: result→gallery completes without a stuck screen")
	await _shot("p6-gallery-after-result-back")

	# P2: the solved puzzle reads ever-completed in the gallery.
	var done_tile := _shell.gallery_screen().tile(PUZZLE_ID)
	_check(done_tile != null and done_tile.status_text() == GalleryTile.COPY_STATUS_DONE,
		"PTU-play-puzzle P2: %s reads %s after the solve" % [PUZZLE_ID, GalleryTile.COPY_STATUS_DONE])
	_check(_shell.gallery_screen().completion_count() >= 1, "PTU-play-puzzle P2: gallery completion moved past zero")

	_finish()


func _drawable_layers(reveal: ResultReveal) -> int:
	var count := 0
	for slot: ResultMorphSlot in [reveal.fills_slot(), reveal.pixel_slot(), reveal.picture_slot()]:
		if slot.opacity() > 0.01 and slot.has_content():
			count += 1
	return count


func _finish() -> void:
	for label in _failures:
		printerr("probe218: FAIL %s" % label)
	if _failures.is_empty():
		print("probe218: RESULT pass (%d checks, %d shots)" % [_checks, _shots_taken.size()])
	else:
		print("probe218: RESULT fail (%d checks, %d failures, %d shots)" % [_checks, _failures.size(), _shots_taken.size()])
	quit(0 if _failures.is_empty() else 1)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("probe218: PASS %s" % label)
	else:
		_failures.append(label)
		printerr("probe218: FAIL %s" % label)


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame
	await RenderingServer.frame_post_draw


func _shot(name: String) -> void:
	if _shot_dir.is_empty():
		return
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "%s/%s.png" % [_shot_dir, name]
	var error := image.save_png(path)
	print("probe218: shot %s -> %s (error %d)" % [name, path, error])
	if error == OK:
		_shots_taken.append(name)
	else:
		_failures.append("the screenshot '%s' did not save (error %d)" % [name, error])


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""
