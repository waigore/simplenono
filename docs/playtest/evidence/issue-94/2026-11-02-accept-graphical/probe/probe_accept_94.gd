## Issue #94 acceptance probe — PTU-gallery-reset + UI-gallery (R1-R3, C1-C3, S1).
##
## Runs on the acceptance build through the real shell, real screens, real controls,
## and real engine frames. Copied into game/ for the run and removed afterwards; no
## product code is changed. The seeded progress document is a test path outside
## user://, so the product save (user://progress.cfg) is never read or written.
##
##     godot --path game -s res://probe_accept_94.gd -- --shot-dir=<run>/screenshots [--no-shots]
extends SceneTree

const SHOT_DIR_ARG := "--shot-dir="
const NO_SHOTS_ARG := "--no-shots"
const SHELL_SCENE := preload("res://presentation/shell.tscn")

## Puzzles the protocol uses. 000 = the reset subject, 001 = ever-completed with a
## best, 002 = in progress, 003 = never touched.
const RESET_ID := "pack-000"
const DONE_ID := "pack-001"
const BUSY_ID := "pack-002"
const NEW_ID := "pack-003"

var _shell: Shell
var _shot_dir := ""
var _shots := false
var _shot_count := 0
var _checks := 0
var _failures: Array[String] = []
var _seed_path := ""
var _temp_dir := ""


func _initialize() -> void:
	_shot_dir = _argument(SHOT_DIR_ARG)
	_shots = not _has_argument(NO_SHOTS_ARG)
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(990, 1680)
	_seed_document()
	# The shell builds its pack in _ready(); swap in a pack on the test document so the
	# gallery reads the seeded facts and the product user://progress.cfg is untouched.
	_shell = SHELL_SCENE.instantiate()
	_shell.set("_pack", Pack.new(_seed_path))
	root.add_child(_shell)
	await _settle(6)

	# ------------------------------------------------------------------ S1 start
	var gallery := _shell.gallery_screen()
	_check(_shell.view() == Shell.GALLERY_VIEW, "UI-gallery S1: app start lands on UI-gallery")
	_check(gallery.tile_count() == gallery.pack_size(), "UI-gallery R2: one tile per accepted definition (%d)" % gallery.tile_count())
	root.size = Vector2i(390, 1200)
	await _settle(4)
	_check(gallery.columns() == GalleryScreen.NARROW_COLUMNS, "UI-gallery S1: two columns at mobile width 390 (%d)" % gallery.columns())
	root.size = Vector2i(990, 1680)
	await _settle(4)
	await _shot("g1-gallery-seeded")

	# R1: completion copy and bar read O2. 50 ever-completed of 200 reads 50 / 200.
	_check(gallery.completion_text() == "Completed 48 / 200", "UI-gallery R1: completion reads 'Completed 48 / 200', got '%s'" % gallery.completion_text())
	_check(is_equal_approx(gallery.completion_rate(), 0.24), "UI-gallery R1: rate is 48/200, got %f" % gallery.completion_rate())

	# R2: the four tile states the approved mockups draw.
	var done := gallery.tile(DONE_ID)
	_check(done != null, "UI-gallery R2: %s has a tile" % DONE_ID)
	if done != null:
		_check(done.status_text() == GalleryTile.COPY_STATUS_DONE, "UI-gallery R2: %s reads Done, got '%s'" % [DONE_ID, done.status_text()])
		_check(done.best_text() != "", "UI-gallery R2: %s shows a personal best when set, got '%s'" % [DONE_ID, done.best_text()])
		_check(done.reset_allowed() and done.reset_visible(), "UI-gallery US1.6: Reset is allowed for the ever-completed %s" % DONE_ID)
	var busy := gallery.tile(BUSY_ID)
	_check(busy != null, "UI-gallery R2: %s has a tile" % BUSY_ID)
	if busy != null:
		_check(busy.status_text() == GalleryTile.COPY_STATUS_IN_PROGRESS, "UI-gallery R2: %s reads In progress, got '%s'" % [BUSY_ID, busy.status_text()])
		_check(busy.best_text() == "", "UI-gallery R2: %s shows no best (none set), got '%s'" % [BUSY_ID, busy.best_text()])
		_check(busy.reset_allowed() and busy.reset_visible(), "UI-gallery US1.6: Reset is allowed for the in-progress %s" % BUSY_ID)
	var fresh := gallery.tile(NEW_ID)
	_check(fresh != null, "UI-gallery R2: %s has a tile" % NEW_ID)
	if fresh != null:
		_check(fresh.status_text() == GalleryTile.COPY_STATUS_NOT_STARTED, "UI-gallery R2: %s reads Not started, got '%s'" % [NEW_ID, fresh.status_text()])
		_check(fresh.best_text() == "", "UI-gallery R2: %s shows no best" % NEW_ID)
		_check(not fresh.reset_allowed() and not fresh.reset_visible(), "UI-gallery US1.6b: Reset is not offered for the not-started %s" % NEW_ID)
		_check(not fresh.shows_picture(), "UI-gallery US1.3: %s draws the generic placeholder (not ever-completed)" % NEW_ID)
	if done != null:
		print("probe94: %s shows_picture=%s (pictures ship in #98)" % [DONE_ID, done.shows_picture()])

	# R3 / C1-C3: the chrome is drawn and enabled.
	_check(_find_button(gallery, GalleryScreen.COPY_SETTINGS) != null, "UI-gallery R3/C3: the settings control is drawn")
	_check(_shell.settings_screen() != null, "UI-gallery R3: the settings route exists")

	# B1: a refused C2 changes nothing and reaches no one.
	var shell_resets := [0]
	_shell.gallery_screen().reset_requested.connect(func(_id: String) -> void: shell_resets[0] += 1)
	var new_before := _snapshot(NEW_ID)
	var refused := gallery.activate_reset(NEW_ID)
	await _settle(2)
	_check(not refused, "SEQ reset B1: C2 on the not-started %s does not fire" % NEW_ID)
	_check(shell_resets[0] == 0, "SEQ reset B1: no reset intent reaches the shell (%d)" % shell_resets[0])
	_check(_snapshot(NEW_ID) == new_before, "SEQ reset B1: the puzzle's record is unchanged")

	# S1: allowed C2 raises the intent to the shell.
	var before := _snapshot(RESET_ID)
	_check(before.ever_completed and before.best > 0, "SEQ reset S1 setup: %s carries a best the reset will clear" % RESET_ID)
	var reset_target := gallery.tile(RESET_ID)
	var fired := gallery.activate_reset(RESET_ID)
	await _settle(3)
	_check(fired, "SEQ reset S1: C2 on the ever-completed %s fires" % RESET_ID)
	_check(shell_resets[0] == 1, "SEQ reset S1: the reset intent reaches CMP-shell (%d)" % shell_resets[0])
	_check(_shell.view() == Shell.GALLERY_VIEW, "SEQ reset S6: the gallery stays in Default (no confirm surface yet, #96)")
	_check(_snapshot(RESET_ID) == before, "SEQ reset S1 hand-off: nothing is cleared without EX.confirm Confirm (#96)")
	await _shot("g2-gallery-c2-fired-no-confirm")

	# ---------------------------------------------------------------- B2 readiness
	# #96 owns EX.confirm (S2 Cancel, S3 Confirm). Record whether the surface exists.
	var confirm_surface := _find_button(_shell, "Confirm") != null or _find_button(_shell, "Cancel") != null
	print("probe94: EX.confirm surface present=%s (owner #96)" % confirm_surface)

	# N2 observation via the write path this epic owns: O7, then the S5 re-read.
	var cleared := _shell.pack().reset(RESET_ID)
	_shell.gallery_screen().refresh()
	await _settle(3)
	_check(cleared, "CTR-pack O7: the pack clears %s" % RESET_ID)
	_check(reset_target != null and reset_target.status_text() == GalleryTile.COPY_STATUS_NOT_STARTED,
		"SEQ reset S5/N2: after O7 the %s tile reads Not started, got '%s'" % [RESET_ID, reset_target.status_text() if reset_target != null else "<none>"])
	_check(reset_target != null and reset_target.best_text() == "", "SEQ reset S5: the personal best is cleared on the tile")
	_check(reset_target != null and not reset_target.reset_allowed(), "SEQ reset S5: C2 is not offered on the reset (not started) tile")
	_check(gallery.completion_text() == "Completed 47 / 200", "SEQ reset S5: the completion count drops, got '%s'" % gallery.completion_text())
	await _shot("g3-gallery-after-o7-refresh")

	# S5 again through the interactive route: leaving a puzzle re-reads O1/O2.
	var busy_tile := gallery.tile(BUSY_ID)
	_check(busy_tile != null, "SEQ reset S5: %s tile present before the leave" % BUSY_ID)
	_check(busy_tile != null and busy_tile.status_text() == GalleryTile.COPY_STATUS_IN_PROGRESS,
		"UI-gallery R2: %s reads In progress after the reopen, got '%s'" % [BUSY_ID, busy_tile.status_text() if busy_tile != null else "<none>"])
	_shell.open_puzzle(BUSY_ID)
	await _settle(4)
	_check(_shell.view() == Shell.PUZZLE_VIEW, "UI-gallery C1: a tile opens its puzzle (NAV.T1 is #95's)")
	var screen := _shell.puzzle_screen()
	if screen != null:
		screen.finish_ready_beat()
		await _settle(2)
	_shell.pack().reset(BUSY_ID)
	_shell.leave_puzzle()
	await _settle(4)
	_check(_shell.view() == Shell.GALLERY_VIEW, "UI-gallery S1: leaving returns to the gallery")
	var busy_after := _shell.gallery_screen().tile(BUSY_ID)
	_check(busy_after != null and busy_after.status_text() == GalleryTile.COPY_STATUS_NOT_STARTED,
		"SEQ reset S5: the leave re-read shows %s as Not started, got '%s'" % [BUSY_ID, busy_after.status_text() if busy_after != null else "<none>"])
	_check(_shell.gallery_screen().completion_text() == "Completed 47 / 200", "SEQ reset S5: completion stays 47 after the leave, reads '%s'" % _shell.gallery_screen().completion_text())
	await _shot("g4-gallery-after-leave-reread")

	# ------------------------------------------------------- landscape / desktop
	root.size = Vector2i(1400, 800)
	await _settle(4)
	var wide := _shell.gallery_screen()
	print("probe94: desktop width columns=%d picture_aspect=%.3f" % [wide.columns(), wide.picture_aspect()])
	_check(wide.columns() == GalleryScreen.WIDE_COLUMNS, "UI-gallery S1: four columns at desktop width (%d)" % wide.columns())
	_check(absf(wide.picture_aspect() - 1.0) < 0.05, "UI-gallery R2: the picture region is square (%.3f)" % wide.picture_aspect())
	await _shot("g5-gallery-desktop")

	_finish()


## Replays the protocol's P1 shape on the shelf: the same puzzle reads Done, then
## reaches the C2 trigger, and O7 leaves it Not started with no personal best.
func _snapshot(puzzle_id: String) -> Dictionary:
	for entry in _shell.pack().list_entries():
		if entry.id == puzzle_id:
			return {"ever_completed": entry.ever_completed, "in_progress": entry.in_progress, "best": entry.personal_best}
	return {}


func _seed_document() -> void:
	# A test-only progress document, never the product user://progress.cfg:
	# 000-049 ever-completed with a best, 050-199 untouched, and 002 in progress.
	var dir := "user://probe-accept-94"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var path := dir.path_join("progress.cfg")
	var config := ConfigFile.new()
	config.set_value("meta", "version", 1)
	# 000-049 ever-completed with a best, except 002 (the in-progress tile) and 003
	# (the never-touched tile). 049 is completed so the count is 48 + 002's replay.
	for index in range(50):
		if index == 2 or index == 3:
			continue
		config.set_value("pack-%03d" % index, "ever-completed", true)
		config.set_value("pack-%03d" % index, "personal-best", 252 + index)
	# 002: in progress — never completed, attempt in progress, marks row-major.
	config.set_value(BUSY_ID, "ever-completed", false)
	config.set_value(BUSY_ID, "in-progress", true)
	config.set_value(BUSY_ID, "elapsed", 41)
	_seed_path = path
	var seed_pack := Pack.new(path)
	seed_pack.load_pack(Pack.PACK_PATH)
	config.set_value(BUSY_ID, "marks", _mark_grid(seed_pack.definition(BUSY_ID).size))
	config.save(path)


## One fill in the top-left corner, the rest clear ([SCH-progress] M2 shape).
func _mark_grid(size: int) -> Array:
	var rows: Array = []
	for row in size:
		var cells: Array = []
		for column in size:
			cells.append("fill" if row == 0 and column == 0 else "clear")
		rows.append(cells)
	return rows


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("PASS  " + label)
	else:
		_failures.append(label)
		print("FAIL  " + label)


func _settle(frames: int) -> void:
	for _i in range(frames):
		await process_frame


func _shot(name: String) -> void:
	if not _shots or _shot_dir == "":
		return
	await RenderingServer.frame_post_draw
	await create_timer(0.05).timeout
	var image := root.get_texture().get_image()
	if image == null:
		return
	var path := _shot_dir.path_join("%02d-%s.png" % [_shot_count, name])
	_shot_count += 1
	image.save_png(path)
	print("SHOT  " + path)


func _find_button(node: Node, text: String) -> Button:
	if node is Button and (node as Button).text == text:
		return node as Button
	for child in node.get_children():
		var found := _find_button(child, text)
		if found != null:
			return found
	return null


func _argument(prefix: String) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(prefix):
			return arg.substr(prefix.length())
	return ""


func _has_argument(value: String) -> bool:
	return OS.get_cmdline_user_args().has(value)


func _finish() -> void:
	print("probe94: %d checks, %d failed" % [_checks, _failures.size()])
	for failure in _failures:
		print("probe94:   - " + failure)
	print("probe94: shots %d" % _shot_count)
	quit(0 if _failures.is_empty() else 1)
