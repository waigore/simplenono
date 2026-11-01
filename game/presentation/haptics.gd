class_name Haptics
extends RefCounted
## [b]HAP.H1[/b]: one slight click on an accepted fill or cross, on iOS and Android only
## (specs/view/haptics.md).
##
## The cue fires once per accepted mark — intensity 0.25 for 20 ms — and never on clear
## or on the desktop platforms. [code]S1[/code] enables or disables it through
## [b]SCH-preferences[/b] F1, which the shell owns; the flag is read when the mark
## arrives, so a later settings change applies without rebuilding this. Visuals and the
## soft mark ticks stay the primary channels: H1 never carries game information alone.
##
## Headless runs cannot assert a device vibration, so playback goes through an injected
## [Sink] and tests record the call. [DeviceSink] is the real [method Input.vibrate_handheld]
## adapter.


## A haptic click. The default sink drives the device; tests inject a recorder.
class Sink:
	extends RefCounted

	func click(_amplitude: float, _duration_ms: int) -> void:
		pass


## The device adapter. Godot ignores the call on platforms without haptics, and
## [method on_mark_accepted] already gates to iOS/Android.
class DeviceSink:
	extends Sink

	func click(amplitude: float, duration_ms: int) -> void:
		Input.vibrate_handheld(duration_ms, amplitude)


## [b]HAP.H1[/b]: intensity 0.25.
const INTENSITY := 0.25

## [b]HAP.H1[/b]: 20 ms.
const DURATION_MS := 20

## [b]HAP.H1[/b]: the platforms with haptics.
const MOBILE_PLATFORMS := ["iOS", "Android"]

var _flags: SessionFlags
var _sink: Sink
var _platform: String


## [param flags] is [b]SCH-preferences[/b] F1's source; [param platform] defaults to the
## running platform and is injected so the platform gate is testable.
func _init(flags: SessionFlags, sink: Sink = null, platform: String = OS.get_name()) -> void:
	_flags = flags
	_sink = sink if sink != null else DeviceSink.new()
	_platform = platform


## [b]HAP.H1[/b] at the mark [b]SEQ-mark[/b] S8 accepted. Returns true when a click fired;
## clear, a non-mobile platform, and F1 off fire nothing.
func on_mark_accepted(kind: CellMark.Mark) -> bool:
	if not _flags.haptics_enabled() or not MOBILE_PLATFORMS.has(_platform):
		return false
	if kind != CellMark.Mark.FILL and kind != CellMark.Mark.CROSS:
		return false
	_sink.click(INTENSITY, DURATION_MS)
	return true
