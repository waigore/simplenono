extends SceneTree
## One phase of the `kill-relaunch` protocol (`specs/technical/verification.md` I10).
##
## `--phase=mark` opens a puzzle, advances elapsed, marks one cell (the commit that
## persists both), dumps the state, and holds until the supervisor kills it.
## `--phase=verify` relaunches, records the launch entry, reopens the same puzzle, and
## asserts the progress record still holds the mark and the elapsed value the mark
## phase's marker reports. Both phases require the one debug seam flag H2 defines.
##
##     godot --headless --path game -s test/integration/relaunch_child.gd -- \
##         --debug-seams --phase=mark --puzzle-id=pack-000 --run-folder=<run>

const EXIT_OK := 0
const EXIT_FAILED := 1
const EXIT_USAGE := 2

const MARK_ROW := 0
const MARK_COLUMN := 0
const MARKED_ELAPSED := 3

var _phase: String = ""
var _run_folder: String = ""
var _puzzle_id: String = ""


func _initialize() -> void:
	var args := IntegrationArgs.parse()
	if not DebugSeams.is_enabled():
		printerr("relaunch: the debug seams are off. Relaunch with --debug-seams.")
		quit(EXIT_USAGE)
		return
	_run_folder = IntegrationArgs.text(args, IntegrationArgs.RUN_DIR)
	_puzzle_id = IntegrationArgs.text(args, IntegrationArgs.PUZZLE_ID, "pack-000")
	_phase = IntegrationArgs.text(args, IntegrationArgs.PHASE)
	if _run_folder.is_empty() or _puzzle_id.is_empty() or _phase.is_empty():
		printerr("relaunch: --phase, --puzzle-id, and --run-dir are required.")
		quit(EXIT_USAGE)
		return
	if _phase != IntegrationRelaunch.PHASE_MARK and _phase != IntegrationRelaunch.PHASE_VERIFY:
		printerr("relaunch: unknown phase %s" % _phase)
		quit(EXIT_USAGE)
		return
	process_frame.connect(_start, CONNECT_ONE_SHOT)


## The scene tree is ready one frame after `_initialize`; the shell's `_ready` needs it.
func _start() -> void:
	if _phase == IntegrationRelaunch.PHASE_MARK:
		var marked := _mark_phase(_run_folder, _puzzle_id)
		if marked != EXIT_OK:
			quit(marked)
		return
	quit(_verify_phase(_run_folder, _puzzle_id))


func _mark_phase(run_folder: String, puzzle_id: String) -> int:
	var shell := _shell()
	# The sequence lives in IntegrationRelaunchMark so the GUT test drives the same order
	# (#604). It persists marks, elapsed, and attempt status before it returns.
	var marked := IntegrationRelaunchMark.run(
		shell, puzzle_id, MARK_ROW, MARK_COLUMN, MARKED_ELAPSED
	)
	if not bool(marked.get("ok", false)):
		return _fail(str(marked.get("message", IntegrationRelaunchMark.MARK_REFUSED)))
	var dump := StateSnapshot.write(
		StateSnapshot.for_attempt(shell.attempt(), shell.pack(), puzzle_id), run_folder
	)
	if dump.is_empty():
		return _fail("could not write the pre-kill dump")
	var marker := {
		"puzzle_id": marked["puzzle_id"],
		"row": marked["row"],
		"column": marked["column"],
		"elapsed": marked["elapsed"],
		"dump": dump,
	}
	# The supervisor kills the child as soon as this file exists, and the commit above has
	# already landed, so the marker is never written ahead of the record it describes.
	if not _write_json(_path(run_folder, IntegrationRelaunch.MARK_FILE), marker):
		return _fail("could not write the mark marker")
	print("RELAUNCH mark held puzzle=%s elapsed=%d" % [puzzle_id, int(marker["elapsed"])])
	return EXIT_OK


func _verify_phase(run_folder: String, puzzle_id: String) -> int:
	var shell := _shell()
	var gallery_entry := shell.view() == Shell.GALLERY_VIEW
	var marker := _read_json(_path(run_folder, IntegrationRelaunch.MARK_FILE))
	var marked_elapsed := int(marker.get("elapsed", 0))
	var opened := shell.open_puzzle(puzzle_id)
	if not opened:
		return _write_verdict(run_folder, gallery_entry, false, false, false, 0, marked_elapsed)
	var attempt := shell.attempt()
	attempt.end_get_set_ready()
	var record := attempt.progress_record()
	var in_progress := record != null and record.in_progress
	var marks_restored := in_progress and _restored_mark(record)
	var elapsed := attempt.state().elapsed() if attempt.state() != null else 0
	# The marker's own elapsed, not the mark phase's constant: a phase that advanced a
	# different amount cannot pass on a bar, and a missing or zero marker fails the leg.
	var elapsed_restored := marked_elapsed > 0 and elapsed == marked_elapsed
	return _write_verdict(
		run_folder, gallery_entry, true, marks_restored, elapsed_restored, elapsed, marked_elapsed
	)


func _write_verdict(
	run_folder: String,
	gallery_entry: bool,
	opened: bool,
	marks_restored: bool,
	elapsed_restored: bool,
	elapsed: int,
	marked_elapsed: int,
) -> int:
	var passed := gallery_entry and opened and marks_restored and elapsed_restored
	var verdict := {
		"gallery_entry": gallery_entry,
		"opened": opened,
		"marks_restored": marks_restored,
		"elapsed_restored": elapsed_restored,
		"elapsed": elapsed,
		"marked_elapsed": marked_elapsed,
		"pass": passed,
	}
	_write_json(_path(run_folder, IntegrationRelaunch.VERIFY_FILE), verdict)
	print(
		(
			"RELAUNCH verify gallery=%s opened=%s marks=%s elapsed=%s pass=%s"
			% [gallery_entry, opened, marks_restored, elapsed_restored, passed]
		)
	)
	return EXIT_OK if passed else EXIT_FAILED


func _restored_mark(record: ProgressRecord) -> bool:
	if record == null or record.marks == null:
		return false
	if MARK_ROW >= record.marks.size or MARK_COLUMN >= record.marks.size:
		return false
	return record.marks.mark_at(MARK_ROW, MARK_COLUMN) == CellMark.Mark.FILL


func _shell() -> Shell:
	var scene := load("res://presentation/shell.tscn") as PackedScene
	var instance := scene.instantiate()
	root.add_child(instance)
	return instance as Shell


func _path(run_folder: String, name: String) -> String:
	return run_folder.trim_suffix("/").path_join(IntegrationRunFolder.LOGS_FOLDER).path_join(name)


func _write_json(path: String, payload: Dictionary) -> bool:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return true


## The mark phase's marker, or an empty dictionary when it is missing or unreadable.
func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


func _fail(message: String) -> int:
	printerr("relaunch: %s" % message)
	return EXIT_FAILED
