class_name AudioFeedback
extends Node
## [b]CMP-shell[/b] R4: the music bed, the mark ticks, and the solve sting
## (specs/technical/asset-access.md G1/G2, specs/aesthetics/sound.md,
## specs/technical/sequences/mark.md S8/S14).
##
## [code]G1[/code]: the three tick streams preload at app start and stay loaded for the
## session. [code]G2[/code]: the bed starts when a puzzle opens, keeps playing under the
## 1 s solve sting, and stops on leave. [code]SND.M2[/code] plays once at
## [b]CTR-attempt[/b] E1, so a duplicate event plays nothing. [b]SCH-preferences[/b]
## [code]I1[/code]: F2 mutes the bed only — ticks and the sting stay audible.
##
## Cues come from [AudioCues] and every stream loads through [AssetResolver]
## ([b]CMP-shell[/b] R6); no path is named here. Headless runs cannot assert audible
## output, so playback goes through an injected [Sink] and tests record the calls.
## [PlayerSink] is the real AudioStreamPlayer adapter.


## A playback sink. The default drives three tick players, a bed player, and a sting
## player; tests inject a recorder.
class Sink:
	extends RefCounted

	func play_tick(_kind: CellMark.Mark, _stream: AudioStream) -> void:
		pass

	func start_bed(_stream: AudioStream) -> void:
		pass

	func stop_bed() -> void:
		pass

	func play_sting(_stream: AudioStream) -> void:
		pass


## The AudioStreamPlayer adapter. One player per tick kind, so a fast drag does not cut
## the previous tick; a separate bed and sting player keep the bed going under the sting.
class PlayerSink:
	extends Sink
	var _ticks: Dictionary = {}
	var _bed: AudioStreamPlayer
	var _sting: AudioStreamPlayer

	func _init(host: Node) -> void:
		for kind in [CellMark.Mark.FILL, CellMark.Mark.CROSS, CellMark.Mark.CLEAR]:
			var player := AudioStreamPlayer.new()
			host.add_child(player)
			_ticks[kind] = player
		_bed = AudioStreamPlayer.new()
		host.add_child(_bed)
		_sting = AudioStreamPlayer.new()
		host.add_child(_sting)

	func play_tick(kind: CellMark.Mark, stream: AudioStream) -> void:
		var player: AudioStreamPlayer = _ticks[kind]
		player.stream = stream
		player.play()

	func start_bed(stream: AudioStream) -> void:
		_bed.stream = stream
		_bed.play()

	func stop_bed() -> void:
		_bed.stop()

	func play_sting(stream: AudioStream) -> void:
		_sting.stream = stream
		_sting.play()


var _resolver: AssetResolver
var _flags: SessionFlags
var _sink: Sink
var _ticks: Dictionary = {}
var _bed: AudioStream
var _sting: AudioStream
var _open := false
var _bed_playing := false
var _sting_played := false


## [param resolver] is [b]CMP-shell[/b] R6; [param flags] is [b]SCH-preferences[/b] F2.
## An injected [param sink] keeps headless tests off the audio device.
func _init(resolver: AssetResolver, flags: SessionFlags, sink: Sink = null) -> void:
	_resolver = resolver
	_flags = flags
	_sink = sink
	_flags.changed.connect(_on_flags_changed)


func _ready() -> void:
	if _sink == null:
		_sink = PlayerSink.new(self)


## [code]ACC.G1[/code]: loads the three mark ticks at app start. The shell calls this
## once after adding this node; every later mark reuses these streams.
func preload_ticks() -> void:
	_ticks[CellMark.Mark.FILL] = _load(AudioCues.FILL_TICK)
	_ticks[CellMark.Mark.CROSS] = _load(AudioCues.CROSS_TICK)
	_ticks[CellMark.Mark.CLEAR] = _load(AudioCues.CLEAR_TICK)


## The preloaded tick for [param kind], or null before [method preload_ticks].
func tick_stream(kind: CellMark.Mark) -> AudioStream:
	return _ticks.get(kind) as AudioStream


## The bed stream, or null before a puzzle opened.
func bed_stream() -> AudioStream:
	return _bed


## The solve sting stream, or null before a puzzle opened or solved.
func sting_stream() -> AudioStream:
	return _sting


## [code]ACC.G2[/code]: a puzzle opened, so the bed may stream and a newer attempt can
## still play its sting. Re-opening in place keeps a running bed.
func on_puzzle_open() -> void:
	_open = true
	_sting_played = false
	if _bed == null:
		_load_bed()
	if _sting == null:
		_sting = _load(AudioCues.SOLVE_STING)
	_refresh_bed()


## [code]ACC.G2[/code]: the puzzle was left, so the bed stops. Ticks and the sting are
## unaffected.
func on_puzzle_leave() -> void:
	_open = false
	_sting_played = false
	_stop_bed()


## [b]SEQ-mark[/b] S8: plays the tick for the accepted [param kind]. The solve branch
## skips S6-S8, so the caller sends nothing on a solve and [method on_solved] plays the
## sting instead ([code]B3[/code]).
func on_mark_accepted(kind: CellMark.Mark) -> void:
	var stream := tick_stream(kind)
	if stream != null:
		_sink.play_tick(kind, stream)


## [b]SEQ-mark[/b] S14 at [b]CTR-attempt[/b] E1: the 1 s sting over the continuing bed,
## exactly once per attempt. A duplicate E1 plays nothing.
func on_solved() -> void:
	if _sting_played:
		return
	_sting_played = true
	if _sting == null:
		_sting = _load(AudioCues.SOLVE_STING)
	if _sting != null:
		_sink.play_sting(_sting)


## [code]SCH-preferences[/code] F2 and [code]I1[/code]: the bed follows the flag, so the
## settings screen never reaches into playback. Ticks and the sting ignore F2.
func _refresh_bed() -> void:
	if _open and not _flags.mute_bgm():
		_start_bed()
	else:
		_stop_bed()


func _on_flags_changed() -> void:
	_refresh_bed()


func _start_bed() -> void:
	if _bed_playing or _bed == null:
		return
	_bed_playing = true
	_sink.start_bed(_bed)


func _stop_bed() -> void:
	if not _bed_playing:
		return
	_bed_playing = false
	_sink.stop_bed()


func _load_bed() -> void:
	_bed = _load(AudioCues.MUSIC_BED)
	if _bed != null and "loop" in _bed:
		_bed.set("loop", true)


## Resolves one cue through [b]CMP-shell[/b] R6 and requires an audio stream, so a
## wrong manifest entry fails loudly instead of playing nothing.
func _load(cue: StringName) -> AudioStream:
	var asset_id := str(AudioCues.ASSET_IDS.get(cue, ""))
	if asset_id.is_empty():
		push_error("AudioFeedback: no asset id for cue %s" % cue)
		return null
	var resource := _resolver.resolve(asset_id)
	if resource == null:
		return null
	var stream := resource as AudioStream
	if stream == null:
		push_error("AudioFeedback: %s resolved to a non-audio resource" % cue)
	return stream
