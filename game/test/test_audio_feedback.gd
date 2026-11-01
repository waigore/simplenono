extends GutTest
## [b]CMP-shell[/b] R4 / [b]HAP.H1[/b]: mark ticks, the bed, the solve sting, and the
## haptic click (specs/technical/asset-access.md G1/G2, specs/aesthetics/sound.md,
## specs/view/haptics.md, specs/technical/sequences/mark.md S8/S14/B1/B2, and
## specs/technical/schemata/preferences.md F1/F2/I1).
##
## Headless has no audio device and no haptic motor, so every playback goes through an
## injected sink and these tests assert the calls. The mark-level scenarios drive the
## real [MarkInput] and [PuzzleScreen], so B1 (blocked or paused) and B2 (the cell
## already has that mark) are proved where the shell hears them.

const SCREEN_SCENE := preload("res://presentation/puzzle.tscn")
const TEAPOT_ID := "teapot"
const TEAPOT_PATH := "res://test/fixtures/teapot.json"

## A clear, non-empty-clue row (the teapot's rows 0-3 auto-cross at ready).
const ROW := 7
const FIRST := 2


## Records the audio sink calls and the streams they carried.
class RecordingSink:
	extends AudioFeedback.Sink
	var calls: Array[String] = []
	var streams: Array[AudioStream] = []

	func play_tick(kind: CellMark.Mark, stream: AudioStream) -> void:
		calls.append("tick:%s" % CellMark.mark_name(kind))
		streams.append(stream)

	func start_bed(stream: AudioStream) -> void:
		calls.append("bed:start")
		streams.append(stream)

	func stop_bed() -> void:
		calls.append("bed:stop")

	func play_sting(stream: AudioStream) -> void:
		calls.append("sting")
		streams.append(stream)


## Records each click as (intensity, duration ms).
class RecordingHapticSink:
	extends Haptics.Sink
	var clicks: Array[Vector2] = []

	func click(amplitude: float, duration_ms: int) -> void:
		clicks.append(Vector2(amplitude, duration_ms))


var _flags: SessionFlags
var _sink: RecordingSink
var _feedback: AudioFeedback
var _haptic_sink: RecordingHapticSink
var _haptics: Haptics
var _accepted: Array[String] = []


func before_each():
	_flags = SessionFlags.new()
	_sink = RecordingSink.new()
	_feedback = AudioFeedback.new(AssetResolver.new(), _flags, _sink)
	add_child_autofree(_feedback)
	_feedback.preload_ticks()
	_haptic_sink = RecordingHapticSink.new()
	_haptics = Haptics.new(_flags, _haptic_sink, "iOS")
	_accepted = []


func after_each():
	Input.action_release("in_drag_paint")


func _record_mark(kind: CellMark.Mark) -> void:
	_accepted.append(CellMark.mark_name(kind))


# ACC.G1: the three tick streams load at app start and stay for the session
func test_three_tick_streams_preload_at_app_start():
	var fill := _feedback.tick_stream(CellMark.Mark.FILL)
	var cross := _feedback.tick_stream(CellMark.Mark.CROSS)
	var clear := _feedback.tick_stream(CellMark.Mark.CLEAR)

	assert_not_null(fill, "the fill tick is loaded")
	assert_not_null(cross, "the cross tick is loaded")
	assert_not_null(clear, "the clear tick is loaded")
	assert_ne(fill, cross, "each mark kind has its own stream")
	assert_ne(cross, clear, "each mark kind has its own stream")


# S8: an accepted fill, cross, and clear each play their own tick
func test_each_accepted_mark_plays_its_own_tick():
	_feedback.on_mark_accepted(CellMark.Mark.FILL)
	_feedback.on_mark_accepted(CellMark.Mark.CROSS)
	_feedback.on_mark_accepted(CellMark.Mark.CLEAR)

	assert_eq(_sink.calls, ["tick:fill", "tick:cross", "tick:clear"])
	assert_eq(_sink.streams[0], _feedback.tick_stream(CellMark.Mark.FILL))
	assert_eq(_sink.streams[2], _feedback.tick_stream(CellMark.Mark.CLEAR))


# G2: the bed starts with the puzzle and stops on leave
func test_bed_starts_on_open_and_stops_on_leave():
	_feedback.on_puzzle_open()
	_feedback.on_puzzle_leave()

	assert_eq(_sink.calls, ["bed:start", "bed:stop"])


# S14: the sting plays exactly once over the continuing bed
func test_solve_plays_the_sting_once_over_the_continuing_bed():
	_feedback.on_puzzle_open()
	_feedback.on_solved()
	_feedback.on_solved()

	assert_eq(_sink.calls, ["bed:start", "sting"], "one sting and no bed stop")
	assert_eq(_sink.streams[1], _feedback.sting_stream(), "the sting is the solve cue")


# I1 / F2: mute silences the bed only; ticks and the sting stay audible
func test_mute_bgm_mutes_the_bed_only():
	_flags.set_mute_bgm(true)
	_feedback.on_puzzle_open()
	_feedback.on_mark_accepted(CellMark.Mark.FILL)
	_feedback.on_solved()

	assert_eq(_sink.calls, ["tick:fill", "sting"], "no bed while muted")

	_flags.set_mute_bgm(false)
	_flags.set_mute_bgm(true)

	assert_eq(
		_sink.calls,
		["tick:fill", "sting", "bed:start", "bed:stop"],
		"the flag starts and stops the bed without touching ticks or the sting",
	)


# HAP.H1: fill and cross click once at 0.25 for 20 ms on iOS/Android
func test_haptic_click_fires_for_fill_and_cross_on_mobile():
	assert_true(_haptics.on_mark_accepted(CellMark.Mark.FILL))
	assert_true(_haptics.on_mark_accepted(CellMark.Mark.CROSS))

	assert_eq(_haptic_sink.clicks, [Vector2(0.25, 20.0), Vector2(0.25, 20.0)])


# HAP.H1: clear fires nothing
func test_haptic_click_ignores_clear():
	assert_false(_haptics.on_mark_accepted(CellMark.Mark.CLEAR))
	assert_eq(_haptic_sink.clicks, [])


# HAP.H1: desktop platforms fire nothing
func test_haptic_click_ignores_desktop_platforms():
	var desktop_sink := RecordingHapticSink.new()
	var desktop := Haptics.new(_flags, desktop_sink, "macOS")

	assert_false(desktop.on_mark_accepted(CellMark.Mark.FILL))
	assert_eq(desktop_sink.clicks, [])


# S1 / F1: haptics off suppresses the click
func test_haptic_click_is_suppressed_when_haptics_are_off():
	_flags.set_haptics_enabled(false)

	assert_false(_haptics.on_mark_accepted(CellMark.Mark.FILL))
	assert_eq(_haptic_sink.clicks, [])


# S8: an accepted tap notifies the shell once, with the applied kind
func test_accepted_tap_notifies_the_shell():
	var screen := _screen_with_attempt()
	_wire(screen)
	_tap_cell(screen, ROW, FIRST)

	assert_eq(_accepted, ["fill"], "one S8 signal for the accepted mark")
	assert_eq(_haptic_sink.clicks.size(), 1, "the click follows the same mark")


# B1: blocked or paused marks send no O2, so no tick or haptic fires
func test_blocked_or_paused_marks_play_nothing():
	var beat_screen := _screen_with_attempt(false)
	_wire(beat_screen)
	_tap_cell(beat_screen, ROW, FIRST)

	var paused_screen := _screen_with_attempt()
	_wire(paused_screen)
	paused_screen.attempt().pause()
	paused_screen.refresh()
	_tap_cell(paused_screen, ROW, FIRST)

	assert_eq(_accepted, [], "B1 accepts no mark")
	assert_eq(_haptic_sink.clicks, [], "B1 fires no click")


# B2: a drag over a cell that already has the mark changes nothing, so it stays silent
func test_unchanged_mark_plays_nothing():
	var screen := _screen_with_attempt()
	_wire(screen)
	screen.select_tool(CellMark.Mark.FILL)
	screen.mark_input().press_cell(ROW, FIRST)
	screen.mark_input().release_stroke()
	_accepted.clear()
	_haptic_sink.clicks.clear()

	screen.mark_input().press_cell(ROW, FIRST)
	screen.mark_input().drag_to_cell(ROW, FIRST + 1)
	screen.mark_input().release_stroke()

	assert_eq(_accepted, ["fill"], "only the changed cell raises S8")
	assert_eq(_haptic_sink.clicks.size(), 1, "only the changed cell clicks")


# F1/F2 and the R4/R6 wiring: the shell owns the flags and starts the bed on open
func test_shell_owns_the_flags_and_wires_the_bed():
	var scene := load("res://presentation/shell.tscn") as PackedScene
	var shell := scene.instantiate() as Shell
	add_child_autofree(shell)

	assert_true(shell.session_flags().haptics_enabled(), "F1 defaults on")
	assert_false(shell.session_flags().mute_bgm(), "F2 defaults off")
	assert_not_null(shell.audio_feedback().tick_stream(CellMark.Mark.FILL), "G1 loaded")
	assert_true(shell.open_puzzle("pack-000"), "a puzzle opens")
	assert_not_null(shell.audio_feedback().bed_stream(), "G2: the bed loads with the puzzle")


func _wire(screen: PuzzleScreen) -> void:
	var input := screen.mark_input()
	input.mark_accepted.connect(_feedback.on_mark_accepted)
	input.mark_accepted.connect(_haptics.on_mark_accepted)
	input.mark_accepted.connect(_record_mark)


func _screen_with_attempt(finish_beat: bool = true) -> PuzzleScreen:
	var definition := _load_definition()
	var pack := Pack.new()
	pack.load_pack("res://test/fixtures/pack/valid.json")
	pack.add_definition(definition)
	var attempt := Attempt.new(pack)
	assert_true(attempt.open(TEAPOT_ID), "the teapot opens")
	var screen := SCREEN_SCENE.instantiate() as PuzzleScreen
	add_child_autofree(screen)
	screen.set_process(false)
	screen.present(attempt)
	if finish_beat:
		screen.finish_ready_beat()
	return screen


func _load_definition() -> PuzzleDefinition:
	var file := FileAccess.open(TEAPOT_PATH, FileAccess.READ)
	assert_not_null(file, "Fixture not readable: %s" % TEAPOT_PATH)
	var entry: Variant = JSON.parse_string(file.get_as_text())
	var reason: Array[String] = []
	var definition := PackEntryValidator.definition_for(_pack_entry(entry), reason)
	assert_not_null(definition, "Fixture is not a valid pack entry: %s" % str(reason))
	return definition


## The teapot fixture names [SCH-puzzle-def] fields with underscores; the pack uses
## hyphens. Same rename as test_mark_input.gd.
func _pack_entry(fixture: Variant) -> Dictionary:
	var entry: Dictionary = {}
	for field in PackEntryValidator.FIELDS:
		var fixture_field := field.replace("-", "_")
		entry[field] = fixture.get(fixture_field)
	return entry


func _tap_cell(screen: PuzzleScreen, row: int, column: int) -> void:
	var input := screen.mark_input()
	input.press_cell(row, column)
	input.release_stroke()
