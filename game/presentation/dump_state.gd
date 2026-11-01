extends SceneTree
## [b]S5[/b] state dump command-line entry (specs/technical/verification.md):
## [code]SIT.3[/code] realized without a display.
##
## Opens one puzzle from the shipped pack, ends get-set-ready, and writes the
## SCH-attempt, SCH-mark-grid, and SCH-progress payload for it under the chosen run
## folder's [code]logs/[/code] ([StateSnapshot]).
##
##     godot --headless --path game -s res://presentation/dump_state.gd -- \
##         --debug-seams --puzzle-id=pack-000 \
##         --run-folder=docs/playtest/evidence/issue-163/<run-id>
##
## Exit codes: 0 written, 1 the puzzle or file failed, 2 a missing argument or the debug
## seams are off ([code]verification.md[/code] H2).

const PUZZLE_ARG := "--puzzle-id="
const RUN_FOLDER_ARG := "--run-folder="
const SESSION_ARG := "--session-id="

const EXIT_OK := 0
const EXIT_FAILED := 1
const EXIT_USAGE := 2


func _initialize() -> void:
	if not DebugSeams.is_enabled():
		printerr("S5: the debug seams are off. Relaunch with --debug-seams.")
		quit(EXIT_USAGE)
		return
	var puzzle_id := _argument(PUZZLE_ARG)
	var run_folder := _argument(RUN_FOLDER_ARG)
	if puzzle_id.is_empty() or run_folder.is_empty():
		printerr("S5: --puzzle-id and --run-folder are required.")
		quit(EXIT_USAGE)
		return
	var pack := Pack.new()
	pack.load_pack(Pack.PACK_PATH)
	var attempt := Attempt.new(pack)
	if not attempt.open(puzzle_id):
		printerr("S5: no such puzzle id: %s" % puzzle_id)
		quit(EXIT_FAILED)
		return
	attempt.end_get_set_ready()
	var path := StateSnapshot.write(StateSnapshot.for_attempt(attempt, pack, puzzle_id), run_folder)
	if path.is_empty():
		printerr("S5: could not write the state dump under %s" % run_folder)
		quit(EXIT_FAILED)
		return
	print("S5: %s %s" % [_session_id(), path])
	quit(EXIT_OK)


func _argument(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _session_id() -> String:
	var session_id := _argument(SESSION_ARG)
	return session_id if not session_id.is_empty() else "session-unknown"
